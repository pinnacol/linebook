module Linebook
  module_function
  
  def __manifest(config)
    paths = config['paths']
    
    manifest = {}
    
    paths.each do |(dir, base, pattern)|
      base_path = File.expand_path(File.join(dir, base))
      start     = base_path.length + 1
      
      Dir.glob(File.join(base_path, pattern)).each do |path|
        rel_path = path[start, path.length - start]
        manifest[rel_path] = path
      end
    end
    
    manifest
  end
end

def Linebook(config)
  Linebook.__manifest(config)
end
