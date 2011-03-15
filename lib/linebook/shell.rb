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
    
    def log_dir
      '/var/log/linecook'
    end
    
    def nest_opts(opts, default={})
      opts = default if opts.nil? || opts == true
      opts && block_given? ? yield(opts) : opts
    end
    
    # Backup a file.
    def backup(path, options={})
      backup_path = "#{path}.bak"
      if options[:mv]
        mv_f path, backup_path
      else
        cp_f path, backup_path
      end
      
      chmod 644, backup_path
      chain_proxy
    end
    
    def _backup(*args, &block) # :nodoc:
      str = capture_block { backup(*args, &block) }
      str.strip!
      str
    end
    
    def directory(target, options={})
      not_if _directory?(target) do 
        mkdir_p target
      end 
      chmod options[:mode] || 755, target
      chown options[:user], options[:group], target
      chain_proxy
    end
    
    def _directory(*args, &block) # :nodoc:
      str = capture_block { directory(*args, &block) }
      str.strip!
      str
    end
    
    # Installs a file from the package.
    def file(file_name, target, options={})
      source = file_path(file_name, guess_target_name(target))
      install(source, target, options)
      chain_proxy
    end
    
    def _file(*args, &block) # :nodoc:
      str = capture_block { file(*args, &block) }
      str.strip!
      str
    end
    
    def group(name, options={})
      not_if _group?(name) do
        groupadd name
      end
      chain_proxy
    end
    
    def _group(*args, &block) # :nodoc:
      str = capture_block { group(*args, &block) }
      str.strip!
      str
    end
    
    def groupmod(name, options={})
      execute 'groupmod', name, options
      chain_proxy
    end
    
    def _groupmod(*args, &block) # :nodoc:
      str = capture_block { groupmod(*args, &block) }
      str.strip!
      str
    end
    
    # Installs a file
    def install(source, target, options={})
      nest_opts(options[:backup], :mv => true) do |opts|
        only_if _file?(target) do
          backup target, opts
        end
      end
      
      nest_opts(options[:directory]) do |opts|
        directory File.dirname(target), opts
      end
      
      cp source, target
      chmod options[:mode] || 644, target
      chown options[:user], options[:group], target
      chain_proxy
    end
    
    def _install(*args, &block) # :nodoc:
      str = capture_block { install(*args, &block) }
      str.strip!
      str
    end
    
    def package(name, version=nil)
      raise NotImplementedError
      chain_proxy
    end
    
    def _package(*args, &block) # :nodoc:
      str = capture_block { package(*args, &block) }
      str.strip!
      str
    end
    
    def recipe(recipe_name)
      target_name = File.join('recipes', recipe_name)
      runlist = target_path "runlist.log"
      recipe_path = _package_.registry.has_key?(target_name) ? 
        target_path(target_name) : 
        self.recipe_path(recipe_name, target_name)
      
      not_if %{grep -xqs "#{recipe_name}" "#{runlist}"} do
        target.puts %{echo "#{recipe_name}" >> "#{runlist}"}
        target.puts %{"#{shell_path}" "#{recipe_path}" $*}
        check_status
      end
      chain_proxy
    end
    
    def _recipe(*args, &block) # :nodoc:
      str = capture_block { recipe(*args, &block) }
      str.strip!
      str
    end
    
    # Installs a template from the package.
    def template(template_name, target, options={})
      locals = options[:locals] || {}
      source = template_path(template_name, guess_target_name(target), 0600, locals)
      install(source, target, options)
      chain_proxy
    end
    
    def _template(*args, &block) # :nodoc:
      str = capture_block { template(*args, &block) }
      str.strip!
      str
    end
    
    def user(name, options={})
      not_if _user?(name) do
        useradd name
      end
      
      
      if groups = options[:groups]
        groups = groups.gsub('*') { "$(#{_groups(name, :sep => ',')})" }
        usermod name, :groups => groups
      end
      chain_proxy
    end
    
    def _user(*args, &block) # :nodoc:
      str = capture_block { user(*args, &block) }
      str.strip!
      str
    end
    
    def userdel(name, options={})
      execute 'userdel', name, options
      chain_proxy
    end
    
    def _userdel(*args, &block) # :nodoc:
      str = capture_block { userdel(*args, &block) }
      str.strip!
      str
    end
    
    def usermod(name, options={})
      execute 'usermod', name, options
      chain_proxy
    end
    
    def _usermod(*args, &block) # :nodoc:
      str = capture_block { usermod(*args, &block) }
      str.strip!
      str
    end
  end
end
