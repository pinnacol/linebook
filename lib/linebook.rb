module Linebook
  module_function
  
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
  
  def __paths(config)
    paths    = __parse_paths(config['paths'] || [])
    gems     = __parse_gems(config['gems'] || [])
    patterns = __parse_patterns(config['patterns'] || [])
    
    __combine(patterns, gems + paths)
  end
  
  def __parse_paths(paths)
    paths.kind_of?(String) ? __split(paths) : paths
  end
  
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
  
  def __parse_patterns(patterns)
    case patterns
    when String then __split(patterns)
    when Hash   then __flatten(patterns)
    else patterns
    end.collect {|pattern| __divide(pattern) }
  end
  
  def __split(str)
    str.kind_of?(String) ? str.split(':') : str
  end
  
  def __divide(pattern)
    pattern.kind_of?(String) ? pattern.split('/', 2) : pattern
  end
  
  def __flatten(hash)
    patterns = []
    hash.each_pair do |base, value|
      __split(value).each do |pattern|
        patterns << [base, pattern]
      end
    end
    patterns
  end
  
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
