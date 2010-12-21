module Linebook
  module_function
  
  def __manifest(config)
    manifest = {}
    
    __paths(config).each do |(dir, base, pattern)|
      base_path = File.expand_path(File.join(dir, base))
      start     = base_path.length + 1
      
      Dir.glob(File.join(base_path, pattern)).each do |path|
        rel_path = path[start, path.length - start]
        manifest[rel_path] = path
      end
    end
    
    manifest
  end
  
  def __paths(config)
    paths    = __normalize_paths(config['paths'] || [])
    patterns = __normalize_patterns(config['patterns'] || [])
    patterns = patterns.collect {|pattern| __normalize_pattern(pattern) }
    
    __combine(patterns, paths)
  end
  
  def __normalize_paths(paths)
    case paths
    when Array  then paths
    when String then __split(paths)
    else raise "invalid paths: #{paths.inspect}"
    end
  end
  
  def __normalize_patterns(patterns)
    case patterns
    when Array  then patterns
    when String then __split(patterns)
    when Hash   then __flatten(patterns)
    else raise "invalid patterns: #{patterns.inspect}"
    end
  end
  
  def __normalize_pattern(pattern)
    case pattern
    when Array  then pattern
    when String then __divide(pattern)
    else raise "invalid pattern: #{pattern.inspect}"
    end
  end
  
  def __split(str)
    str.split(':')
  end
  
  def __divide(str)
    str.split('/', 2)
  end
  
  def __flatten(hash)
    results = []
    hash.each_pair do |base, patterns|
      if patterns.kind_of?(String)
        patterns = __split(patterns)
      end
      
      patterns.each do |pattern|
        results << [base, pattern]
      end
    end
    results
  end
  
  def __combine(patterns, paths)
    combinations = []
    paths.each do |path|
      case path
      when Array
        combinations << path
        
      when String
        patterns.each do |(base, pattern)|
          combinations << [path, base, pattern]
        end
        
      else
        raise "invalid path: #{path.inspect}"
      end
    end
    combinations
  end
end

def Linebook(config)
  Linebook.__manifest(config)
end
