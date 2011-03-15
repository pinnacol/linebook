require 'erb'

module Linebook
  module Os
    # == login vs su
    #
    # The login and su methods both provide a way to switch users.  Login
    # simulates a login and therefore you end up in the user home directory with
    # the ENV as setup during login. By contrast su switches users such that it
    # preserves exported ENV variables, including the pwd.
    #
    # Say you were the linecook user:
    #
    #   cd
    #   export 'A', 'a'
    #   variable 'B', 'b'
    #   echo "$(whoami):$(pwd):$A:$B"             # => linecook:/home/linecook:a:b
    #   login { echo "$(whoami):$(pwd):$A:$B" }   # => root:/root::
    #   su    { echo "$(whoami):$(pwd):$A:$B" }   # => root:/home/linecook:a:
    #
    # User-management methods in this module assume root privileges (useradd,
    # groupadd, etc) so unless you are already root, you need to wrap them in
    # login or su. In this case login is more reliable than su because some
    # systems leave the user management commands off the non-root PATH; using
    # login ensures PATH will be set for root during the block.
    #
    # For example use:
    #
    #   login { useradd 'username' }
    #
    # Rather than:
    #
    #   su { useradd 'username' }   # => may give 'useradd: command not found'
    #
    # == Permissions
    #
    # The user running the package needs the ability to su without a password,
    # otherwise login/su will choke and fail when run by 'linecook run'.  How this
    # is accomplished is a matter of policy; something each user needs to decide
    # for themselves.
    #
    # First you could run the package as root.
    #
    # Second you can grant the running user (ex 'linecook') su privileges.  This
    # can be accomplished by adding the user to the 'wheel' group and modifiying
    # the PAM config files. Afterwards all wheel users can su without a password.
    # To do so (repeat for '/etc/pam.d/su-l' if it exists):
    #
    #   vi /etc/pam.d/su
    #   # insert:
    #   #   auth       sufficient pam_wheel.so trust
    # 
    # This is the default strategy and it works in a portable way because the
    # {linux spec}[http://refspecs.linuxfoundation.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/cmdbehav.html]
    # requires su exists and has the necessary options.
    #
    # Third you can chuck the default login/su, reimplement them with sudo, and
    # give the user (ex 'linecook') sudo privileges.  This can be accomplished by
    # adding the user to a group (ex 'linecook') and modifying the sudo config via
    # visudo. Afterwards all the linecook users can sudo without a password.
    #
    #   visudo
    #   # insert:
    #   #   # Members of the linecook group may sudo without a password
    #   #   %linecook ALL=NOPASSWD: ALL
    #
    # See an old version of the {linebook source}[https://github.com/pinnacol/linebook/tree/b786e1e63c68f5ddf3be15851d9b423bc05e5345/helpers/linebook/os/linux]
    # for hints on how login/su could be reimplemented with sudo.  This strategy
    # was abandonded as the default because sudo is not required by the linux spec
    # and is does not come installed in many cases (ex Debian).  Moreover the
    # options needed to make this strategy work don't exist in sudo < 1.7, so even
    # systems that come with sudo could need an upgrade.
    #
    # Lastly you can chuck all of these strategies and figure out your own way.
    # Surely they exist, for example by running the packages manually and entering
    # in passwords as prompted.
    #
    module Linux
      require 'linebook/os/unix'
      include Unix
      
      # Returns true if the group exists as determined by checking /etc/group.
      def group?(name)
        #  grep "^<%= name %>:" /etc/group >/dev/null 2>&1
        write "grep \"^"; write(( name ).to_s); write ":\" /etc/group >/dev/null 2>&1"
        chain_proxy
      end
      
      def _group?(*args, &block) # :nodoc:
        str = capture_block { group?(*args, &block) }
        str.strip!
        str
      end
      
      # Adds the group.
      def groupadd(name, options={})
        execute 'groupadd', name, options
        chain_proxy
      end
      
      def _groupadd(*args, &block) # :nodoc:
        str = capture_block { groupadd(*args, &block) }
        str.strip!
        str
      end
      
      # Removes the group.
      def groupdel(name, options={})
        execute 'groupdel', name, options
        chain_proxy
      end
      
      def _groupdel(*args, &block) # :nodoc:
        str = capture_block { groupdel(*args, &block) }
        str.strip!
        str
      end
      
      def groups(user, options={})
        #  id -Gn <%= quote(user) %>
        #  
        #  
        write "id -Gn "; write(( quote(user) ).to_s); write "\n"
        write "\n"
      
        chain_proxy
      end
      
      def _groups(*args, &block) # :nodoc:
        str = capture_block { groups(*args, &block) }
        str.strip!
        str
      end
      
      def install(source, target, options={})
        execute 'install', source, target, options
        chain_proxy
      end
      
      def _install(*args, &block) # :nodoc:
        str = capture_block { install(*args, &block) }
        str.strip!
        str
      end
      
      # Logs in as the specified user for the duration of a block (the current ENV
      # and pwd are reset as during a normal login).
      def login(user='root', &block)
        current = functions
        begin
          @functions = []
          target_name = guess_target_name(user)
          path = capture_path(target_name, 0700, &block)
          execute 'su', user, path, :l => true
        ensure
          @functions = current
        end
        chain_proxy
      end
      
      def _login(*args, &block) # :nodoc:
        str = capture_block { login(*args, &block) }
        str.strip!
        str
      end
      
      # Switches to the specified user for the duration of a block.  The current ENV
      # and pwd are preserved.
      def su(user='root', &block)
        target_name = guess_target_name(user)
        path = capture_path(target_name, 0700) do
          functions.each do |function|
            writeln function
          end
          instance_eval(&block)
        end
        execute 'su', user, path, :m => true
        chain_proxy
      end
      
      def _su(*args, &block) # :nodoc:
        str = capture_block { su(*args, &block) }
        str.strip!
        str
      end
      
      # Returns true if the user exists as determined by id.
      def user?(name)
        #  id <%= quote(name) %> >/dev/null 2>&1
        write "id "; write(( quote(name) ).to_s); write " >/dev/null 2>&1"
        chain_proxy
      end
      
      def _user?(*args, &block) # :nodoc:
        str = capture_block { user?(*args, &block) }
        str.strip!
        str
      end
      
      # Adds the user.
      def useradd(name, options={}) 
        execute 'useradd', name, options
        chain_proxy
      end
      
      def _useradd(*args, &block) # :nodoc:
        str = capture_block { useradd(*args, &block) }
        str.strip!
        str
      end
      
      # Removes the user.
      def userdel(name, options={}) 
        # TODO - look into other things that might need to happen before:
        # * kill processes belonging to user
        # * remove at/cron/print jobs etc. 
        execute 'userdel', name, options
        chain_proxy
      end
      
      def _userdel(*args, &block) # :nodoc:
        str = capture_block { userdel(*args, &block) }
        str.strip!
        str
      end
    end
  end
end
