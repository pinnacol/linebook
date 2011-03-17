require 'erb'

module Linebook
  module Os
    module Unix
      require 'linebook/os/posix'
      include Posix
      
      def guess_target_name(source_name)
        target_dir  = File.dirname(target_name)
        name = File.basename(source_name)
        
        _package_.next_target_name(target_dir == '.' ? name : File.join(target_dir, name))
      end
      
      def close
        unless closed? 
          if @shebang ||= false
            section " (#{target_name}) "
          end
        end
        
        super
      end
      
      # Executes 'cat' with the sources.
      def cat(*sources)
        execute 'cat', *sources
        chain_proxy
      end
      
      def _cat(*args, &block) # :nodoc:
        str = capture_block { cat(*args, &block) }
        str.strip!
        str
      end
      
      def cd(dir=nil)
        if block_given?
          var = _package_.next_variable_name('cd')
          writeln %{#{var}=$(pwd)}
        end
      
        execute "cd", dir
      
        if block_given?
          yield
          execute "cd", "$#{var}"
        end
        chain_proxy
      end
      
      def _cd(*args, &block) # :nodoc:
        str = capture_block { cd(*args, &block) }
        str.strip!
        str
      end
      
      # Makes a command to chmod a file or directory.  Provide the mode as the
      # literal string that should go into the statement:
      # 
      #   chmod "600" target
      def chmod(mode, target)
        if mode
          execute 'chmod', mode, target
        end
        chain_proxy
      end
      
      def _chmod(*args, &block) # :nodoc:
        str = capture_block { chmod(*args, &block) }
        str.strip!
        str
      end
      
      # Makes a command to chown a file or directory.
      def chown(user, group, target)
        if user || group
          execute 'chown', "#{user}:#{group}", target
        end
        chain_proxy
      end
      
      def _chown(*args, &block) # :nodoc:
        str = capture_block { chown(*args, &block) }
        str.strip!
        str
      end
      
      # Copy source to target.  Accepts a hash of command line options.
      def cp(source, target, options={})
        execute 'cp', source, target, options
        chain_proxy
      end
      
      def _cp(*args, &block) # :nodoc:
        str = capture_block { cp(*args, &block) }
        str.strip!
        str
      end
      
      # Copy source to target, with -f.
      def cp_f(source, target)
        cp source, target, '-f' => true
        chain_proxy
      end
      
      def _cp_f(*args, &block) # :nodoc:
        str = capture_block { cp_f(*args, &block) }
        str.strip!
        str
      end
      
      # Copy source to target, with -r.
      def cp_r(source, target)
        cp source, target, '-r'=> true
        chain_proxy
      end
      
      def _cp_r(*args, &block) # :nodoc:
        str = capture_block { cp_r(*args, &block) }
        str.strip!
        str
      end
      
      # Copy source to target, with -rf.
      def cp_rf(source, target)
        cp source, target, '-rf' => true
        chain_proxy
      end
      
      def _cp_rf(*args, &block) # :nodoc:
        str = capture_block { cp_rf(*args, &block) }
        str.strip!
        str
      end
      
      # Returns the current system time.  A format string may be provided, as well as
      # a hash of command line options.
      def date(format=nil, options={})
        if format
          format = "+#{quote(format)}"
        end
        
        execute "date", format, options
        chain_proxy
      end
      
      def _date(*args, &block) # :nodoc:
        str = capture_block { date(*args, &block) }
        str.strip!
        str
      end
      
      def directory?(path)
        #  [ -d "<%= path %>" ]
        write "[ -d \""; write(( path ).to_s); write "\" ]"
        chain_proxy
      end
      
      def _directory?(*args, &block) # :nodoc:
        str = capture_block { directory?(*args, &block) }
        str.strip!
        str
      end
      
      # Echo the args.
      def echo(*args)
        execute 'echo', *args
        chain_proxy
      end
      
      def _echo(*args, &block) # :nodoc:
        str = capture_block { echo(*args, &block) }
        str.strip!
        str
      end
      
      def exists?(path)
        #  [ -e "<%= path %>" ]
        write "[ -e \""; write(( path ).to_s); write "\" ]"
        chain_proxy
      end
      
      def _exists?(*args, &block) # :nodoc:
        str = capture_block { exists?(*args, &block) }
        str.strip!
        str
      end
      
      def file?(path)
        #  [ -f "<%= path %>" ]
        write "[ -f \""; write(( path ).to_s); write "\" ]"
        chain_proxy
      end
      
      def _file?(*args, &block) # :nodoc:
        str = capture_block { file?(*args, &block) }
        str.strip!
        str
      end
      
      # Sets up a gsub using sed.
      def gsub(pattern, replacement, *args)
        unless args.last.kind_of?(Hash)
          args << {}
        end
        args.last[:e] = "s/#{pattern}/#{replacement}/g"
        sed(*args)
        chain_proxy
      end
      
      def _gsub(*args, &block) # :nodoc:
        str = capture_block { gsub(*args, &block) }
        str.strip!
        str
      end
      
      # Link source to target.  Accepts a hash of command line options.
      def ln(source, target, options={})
        execute 'ln', source, target, options
        chain_proxy
      end
      
      def _ln(*args, &block) # :nodoc:
        str = capture_block { ln(*args, &block) }
        str.strip!
        str
      end
      
      # Copy source to target, with -s.
      def ln_s(source, target)
        ln source, target, '-s' => true
        chain_proxy
      end
      
      def _ln_s(*args, &block) # :nodoc:
        str = capture_block { ln_s(*args, &block) }
        str.strip!
        str
      end
      
      # Make a directory.  Accepts a hash of command line options.
      def mkdir(path, options={})
        execute 'mkdir', path, options
        chain_proxy
      end
      
      def _mkdir(*args, &block) # :nodoc:
        str = capture_block { mkdir(*args, &block) }
        str.strip!
        str
      end
      
      # Make a directory, and parent directories as needed.
      def mkdir_p(path)
        mkdir path, '-p' => true
        chain_proxy
      end
      
      def _mkdir_p(*args, &block) # :nodoc:
        str = capture_block { mkdir_p(*args, &block) }
        str.strip!
        str
      end
      
      # Move source to target.  Accepts a hash of command line options.
      def mv(source, target, options={})
        execute 'mv', source, target, options
        chain_proxy
      end
      
      def _mv(*args, &block) # :nodoc:
        str = capture_block { mv(*args, &block) }
        str.strip!
        str
      end
      
      # Move source to target, with -f.
      def mv_f(source, target)
        mv source, target, '-f' => true
        chain_proxy
      end
      
      def _mv_f(*args, &block) # :nodoc:
        str = capture_block { mv_f(*args, &block) }
        str.strip!
        str
      end
      
      # Unlink a file.  Accepts a hash of command line options.
      def rm(path, options={})
        execute 'rm', path, options
        chain_proxy
      end
      
      def _rm(*args, &block) # :nodoc:
        str = capture_block { rm(*args, &block) }
        str.strip!
        str
      end
      
      # Unlink a file or directory, with -r.
      def rm_r(path)
        rm path, '-r' => true
        chain_proxy
      end
      
      def _rm_r(*args, &block) # :nodoc:
        str = capture_block { rm_r(*args, &block) }
        str.strip!
        str
      end
      
      # Unlink a file or directory, with -rf.
      def rm_rf(path)
        rm path, '-rf' => true
        chain_proxy
      end
      
      def _rm_rf(*args, &block) # :nodoc:
        str = capture_block { rm_rf(*args, &block) }
        str.strip!
        str
      end
      
      def section(comment="")
        n = (78 - comment.length)/2
        str = "-" * n
        #  #<%= str %><%= comment %><%= str %><%= "-" if comment.length % 2 == 1 %>
        #  
        write "#"; write(( str ).to_s); write(( comment ).to_s); write(( str ).to_s); write(( "-" if comment.length % 2 == 1 ).to_s); write "\n"
      
        chain_proxy
      end
      
      def _section(*args, &block) # :nodoc:
        str = capture_block { section(*args, &block) }
        str.strip!
        str
      end
      
      # Execute sed.
      def sed(*args)
        execute 'sed', *args
        chain_proxy
      end
      
      def _sed(*args, &block) # :nodoc:
        str = capture_block { sed(*args, &block) }
        str.strip!
        str
      end
      
      # Sets the options to on (true) or off (false) as specified.  If a block is
      # given then options will only be reset when the block completes.
      def set(options)
        if block_given?
          var = _package_.next_variable_name('set')
          patterns = options.keys.collect {|key| "-e #{key}" }.sort
          writeln %{#{var}=$(set +o | grep #{patterns.join(' ')})}
        end
      
        super
      
        if block_given?
          yield
          writeln %{eval "$#{var}"}
        end
        chain_proxy
      end
      
      def _set(*args, &block) # :nodoc:
        str = capture_block { set(*args, &block) }
        str.strip!
        str
      end
      
      # Sets the system time.  Must be root for this to succeed.
      def set_date(time=Time.now) 
        #  date -u <%= time.dup.utc.strftime("%m%d%H%M%Y.%S") %>
        #  <% check_status %>
        write "date -u "; write(( time.dup.utc.strftime("%m%d%H%M%Y.%S") ).to_s); write "\n"
        check_status 
        chain_proxy
      end
      
      def _set_date(*args, &block) # :nodoc:
        str = capture_block { set_date(*args, &block) }
        str.strip!
        str
      end
      
      def shebang(options={})
        @shebang = true
        #  #!<%= options[:program] || '/bin/sh' %>
        #  <% section %>
        #  
        #  usage="usage: %s: [-h]\n"
        #  while getopts "h" opt
        #  do
        #    case $opt in
        #    h  )  printf "$usage" $0
        #          printf "       %s   %s\n" "-h" "prints this help"
        #          exit 0 ;;
        #    \? )  printf "$usage" $0
        #          exit 2 ;;
        #    esac
        #  done
        #  shift $(($OPTIND - 1))
        #  
        #  <% check_status_function %>
        #  <% yield if block_given? %>
        #  
        #  <% if options[:info] %>
        #  echo >&2
        #  echo "###############################################################################" >&2
        #  echo "# $(whoami)@$(hostname):$(pwd):$0" >&2
        #  
        #  <% end %>
        #  <% section " #{target_name} " %>
        #  
        #  
        write "#!"; write(( options[:program] || '/bin/sh' ).to_s); write "\n"
        section 
        write "\n"
        write "usage=\"usage: %s: [-h]\\n\"\n"
        write "while getopts \"h\" opt\n"
        write "do\n"
        write "  case $opt in\n"
        write "  h  )  printf \"$usage\" $0\n"
        write "        printf \"       %s   %s\\n\" \"-h\" \"prints this help\"\n"
        write "        exit 0 ;;\n"
        write "  \\? )  printf \"$usage\" $0\n"
        write "        exit 2 ;;\n"
        write "  esac\n"
        write "done\n"
        write "shift $(($OPTIND - 1))\n"
        write "\n"
        check_status_function 
        yield if block_given? 
        write "\n"
        if options[:info] 
        write "echo >&2\n"
        write "echo \"###############################################################################\" >&2\n"
        write "echo \"# $(whoami)@$(hostname):$(pwd):$0\" >&2\n"
        write "\n"
        end 
        section " #{target_name} " 
        write "\n"
      
        chain_proxy
      end
      
      def _shebang(*args, &block) # :nodoc:
        str = capture_block { shebang(*args, &block) }
        str.strip!
        str
      end
    end
  end
end
