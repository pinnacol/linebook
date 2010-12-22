
# Linebook provides methods to generate a manifest of files spread across
# multiple directories. Manifests merge the contents of the directories such
# that files can be looked up across multiple directories using relative
# paths. Manifests are generated using __manifest, which is aliased the
# 'Linebook' method.
#
# Given these files:
# 
#   /pwd/lib/one.rb
#   /gem/a/lib/two.rb
#   /gem/b/lib/three.rb
# 
# Manifest generation looks like this:
#
#   Linebook('patterns' => 'lib/*/**.rb', 'paths' => '/pwd', 'gems' => 'a:b')
#   # => {
#   #   'one.rb'   => '/pwd/lib/one.rb', 
#   #   'two.rb'   => '/gem/a/lib/two.rb',
#   #   'three.rb' => '/gem/b/lib/three.rb'
#   # }
#
# See below for config variations.
#
# == Config
# 
# Linebook uses directories, base paths, and patterns to find files and
# determine the relative paths used in the manifest. The config literally
# defines (in a highly redundant way) what to glob, and how to slice the
# results. A basic config looks like this:
# 
#   { 'paths' => [['/dir', 'base', 'pattern']] }
# 
# And corresponds to this pseudocode:
# 
#   for each path in paths
#     glob files '/dir/base/pattern'
#     for each file in files
#       record file using the path relative to '/dir/base'
#       (override previous file, if it exists)
# 
# Configs can be written in several compact forms that expand into [dir, base,
# pattern] arrays. The expansion works in several steps. For illustration
# pretend you're on a system where case matters; configs can be written with
# any combination of the following:
# 
#   # string form
#   { 'patterns' => 'base/pattern:BASE/PATTERN',
#     'paths'    => '/dir:/DIR' }
#   
#   # split form
#   { 'patterns' => [['base', 'pattern'], ['BASE', 'PATTERN']]
#     'paths'    => ['/dir', '/DIR'] }
#   
#   # path form
#   { 'paths'    => [
#       ['/dir', 'base', 'pattern'], 
#       ['/dir', 'BASE', 'PATTERN'],
#       ['/DIR', 'base', 'pattern'],
#       ['/DIR', 'BASE', 'PATTERN']]}
# 
# When order doesn't matter the patterns can be written as a hash:
# 
#   # multiple bases (base order indeterminate)
#   { 'patterns' => {'base' => 'pattern', 'BASE' => 'PATTERN'} }
#   
#   # multiple patterns per-base
#   { 'patterns' => {'base' => 'pattern:PATTERN'} }
#   { 'patterns' => {'base' => ['pattern', 'PATTERN']} }
# 
# When the paths point to gems, the gem names may be specified as 'gems' in
# the same way as paths. The path to the latest version will be used. Linebook
# has no notion of dependencies; something like
# {Bundler}[http://gembundler.com/], {RVM}[http://rvm.beginrescueend.com/] or
# personal diligence needs to ensure the latest version is the correct version
# to use. Gems are considered before paths, so these are the same:
# 
#   { 'patterns' => 'base/pattern:BASE/PATTERN',
#     'gems'     => 'name',
#     'paths'    => '/dir' }
#   
#   { 'paths'    => [
#       ['/path/to/name', 'base', 'pattern'], 
#       ['/path/to/name', 'BASE', 'PATTERN'], 
#       ['/dir', 'base', 'pattern'],
#       ['/dir', 'BASE', 'PATTERN']]}
# 
# Lastly, you can manually override any result using 'manifest'. The manifest
# hash is merged over the files founds along paths.
# 
#   { 'manifest'  => {'relative/path' => '/full/path'} }
#
# == Implementation Notes
# 
# Linebook is constructed using a series of module functions, which may seem
# peculiar. Although Linebook is a standalone library, it is primarily the
# distribution module for {Linecook}[http://gemcutter.org/gems/linecook].
# Linecook needs a clean namespace so that users can name helpers as they
# please; Linebook was made without any internal constants for that purpose.
# 
# Likewise the helper methods used by Linebook all start with a double
# underscore, again to keep the module as clean as possible.
module Linebook
  module_function
  
  # Generate the manifest from a config.
  def __manifest(config)
    manifest  = {}
    overrides = config['manifest'] || {}
    
    __paths(config).each do |(dir, base, pattern)|
      base_path = File.expand_path(File.join(dir, base))
      start     = base_path.length + 1
      
      Dir.glob(File.join(base_path, pattern)).each do |path|
        rel_path = path[start, path.length - start]
        manifest[rel_path] = path
      end
    end
    
    manifest.merge!(overrides)
    manifest
  end
  
  # Parses config to return an array of [dir, base, pattern] paths.
  def __paths(config)
    paths    = __parse_paths(config['paths'] || [])
    gems     = __parse_gems(config['gems'] || [])
    patterns = __parse_patterns(config['patterns'] || [])
    
    __combine(patterns, gems + paths)
  end
  
  # Parses the 'paths' config by splitting strings into an array.
  def __parse_paths(paths)
    paths.kind_of?(String) ? __split(paths) : paths
  end
  
  # Parses the 'gems' config by splitting strings into an array, and resolving
  # each name to the corresponding full_gem_path.
  def __parse_gems(gems)
    gems = gems.kind_of?(String) ? __split(gems) : gems
    
    unless gems.empty?
      specs = __latest_specs
      gems  = gems.collect do |name| 
        spec = specs[name] or raise "no such gem: #{name.inspect}"
        spec.full_gem_path
      end
    end
    
    gems
  end
  
  # Parses the 'patterns' config by splitting string patterns, flattening hash
  # patterns, and then dividing each pattern into a [base, pattern] pair.
  def __parse_patterns(patterns)
    case patterns
    when String then __split(patterns)
    when Hash   then __flatten(patterns)
    else patterns
    end.collect {|pattern| __divide(pattern) }
  end
  
  # Splits the string into an array along colons.  Returns non-string inputs.
  def __split(str)
    str.kind_of?(String) ? str.split(':') : str
  end
  
  # Divides a string pattern into a [base, pattern] pair.  Returns non-string
  # patterns.
  def __divide(pattern)
    pattern.kind_of?(String) ? pattern.split('/', 2) : pattern
  end
  
  # Flattens a patterns hash into an array of patterns.
  def __flatten(hash)
    patterns = []
    hash.each_pair do |base, value|
      __split(value).each do |pattern|
        patterns << [base, pattern]
      end
    end
    patterns
  end
  
  # Combines patterns and paths into [path, base, pattern] arrays.
  def __combine(patterns, paths)
    combinations = []
    paths.each do |path|
      if path.kind_of?(String)
        patterns.each do |(base, pattern)|
          combinations << [path, base, pattern]
        end
      else
        combinations << path
      end
    end
    combinations
  end
  
  # Returns a hash of the latest specs available in Gem.source_index.
  def __latest_specs
    latest = {}
    Gem.source_index.latest_specs.each do |spec|
      latest[spec.name] = spec
    end
    latest
  end
end

def Linebook(config)
  Linebook.__manifest(config)
end
