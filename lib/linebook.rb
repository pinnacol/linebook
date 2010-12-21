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
    paths    = __split(config['paths'] || [])
    patterns = __split(config['patterns'] || [])
    patterns = patterns.collect {|pattern| __divide(pattern) }
    
    __combine(patterns, paths)
  end
  
  def __split(str)
    str.kind_of?(String) ? str.split(':') : str
  end
  
  def __divide(str)
    str.kind_of?(String) ? str.split('/', 2) : str
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
