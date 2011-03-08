require 'erb'

# Generated by Linecook, do not edit.
module Linebook
  module Os
    module Linux
      require 'linebook/os/unix'
      include Unix
      
      # Logs in as a different user for the duration of a block.
      def login(user='root', &block)
        target_name = guess_target_name(user)
        path = capture_path(target_name, &block)
        chmod '+x', path
        execute 'su', user, path, :l => true
        self
      end
      
      def _login(*args, &block) # :nodoc:
        capture { login(*args, &block) }
      end
      
      # Switches to a different user for the duration of a block.
      def su(user='root', &block)
        target_name = guess_target_name(user)
        path = capture_path(target_name, &block)
        chmod '+x', path
        execute 'su', user, path, :m => true
        self
      end
      
      def _su(*args, &block) # :nodoc:
        capture { su(*args, &block) }
      end
      
      # Adds the user.  Assumes the current user is root, or has root privileges.
      def useradd(name, options={})
        #  useradd <%= format_options(options) %> <%= name %>
        #  
        _erbout.concat "useradd "; _erbout.concat(( format_options(options) ).to_s); _erbout.concat " "; _erbout.concat(( name ).to_s); _erbout.concat "\n"
        self
      end
      
      def _useradd(*args, &block) # :nodoc:
        capture { useradd(*args, &block) }
      end
    end
  end
end
