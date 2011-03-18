require 'erb'

module Linebook
  module Shell
    def self.extended(base)
      base.attributes 'linebook/shell'
      
      if os = base.attrs['linebook']['os']
        base.helpers os
      end
      
      if shell = base.attrs['linebook']['shell']
        base.helpers shell
      end
      
      super
    end
    
    def directory(target, options={})
      unless_ _directory?(target) do 
        mkdir_p target
      end 
      chmod options[:mode] || 755, target
      chown options[:owner], options[:group], target
      chain_proxy
    end
    
    def _directory(*args, &block) # :nodoc:
      str = capture_str { directory(*args, &block) }
      str.strip!
      str
    end
    
    # Installs a file from the package.
    def file(file_name, target, options={})
      source = file_path(file_name, guess_target_name(target))
      options = {:D => true}.merge(options)
      install(source, target, options)
      chain_proxy
    end
    
    def _file(*args, &block) # :nodoc:
      str = capture_str { file(*args, &block) }
      str.strip!
      str
    end
    
    def group(name, options={})
      unless_ _group?(name) do
        groupadd name
      end
      chain_proxy
    end
    
    def _group(*args, &block) # :nodoc:
      str = capture_str { group(*args, &block) }
      str.strip!
      str
    end
    
    def package(name, version=nil)
      raise NotImplementedError
      chain_proxy
    end
    
    def _package(*args, &block) # :nodoc:
      str = capture_str { package(*args, &block) }
      str.strip!
      str
    end
    
    def recipe(recipe_name)
      target_name = File.join('recipes', recipe_name)
      recipe_path = _package_.registry.has_key?(target_name) ? 
        target_path(target_name) : 
        self.recipe_path(recipe_name, target_name, 0777)
    
      dir = target_path File.join('tmp', recipe_name)
      unless_ _directory?(dir) do
        current = target_path('tmp')
        recipe_name.split('/').each do |segment|
          current = File.join(current, segment)
          directory current, :mode => 770
        end
        writeln "#{quote(recipe_path)} $*"
        check_status
      end
      chain_proxy
    end
    
    def _recipe(*args, &block) # :nodoc:
      str = capture_str { recipe(*args, &block) }
      str.strip!
      str
    end
    
    # Installs a template from the package.
    def template(template_name, target, options={})
      locals = options.delete(:locals) || {}
      source = template_path(template_name, guess_target_name(target), 0600, locals)
      options = {:D => true}.merge(options)
      install(source, target, options)
      chain_proxy
    end
    
    def _template(*args, &block) # :nodoc:
      str = capture_str { template(*args, &block) }
      str.strip!
      str
    end
    
    def user(name, options={})
      unless_ _user?(name) do
        useradd name, options
      end
      chain_proxy
    end
    
    def _user(*args, &block) # :nodoc:
      str = capture_str { user(*args, &block) }
      str.strip!
      str
    end
    
    def userdel(name, options={})
      execute 'userdel', name, options
      chain_proxy
    end
    
    def _userdel(*args, &block) # :nodoc:
      str = capture_str { userdel(*args, &block) }
      str.strip!
      str
    end
    
    def usermod(name, options={})
      execute 'usermod', name, options
      chain_proxy
    end
    
    def _usermod(*args, &block) # :nodoc:
      str = capture_str { usermod(*args, &block) }
      str.strip!
      str
    end
  end
end
