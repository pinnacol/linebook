require 'erb'

module Linebook
  module Os
    module Unix
      require 'linebook/os/posix'
      include Posix
      
      def guess_target_name(source_name)
        next_target_name File.join("#{target_name}.d", File.basename(source_name))
      end
      
      def close
        unless closed?
          section " (#{target_name}) "
        end
        
        super
      end
      
      # Executes 'cat' with the sources.
      def cat(*sources)
        execute 'cat', *sources
        chain_proxy
      end
      
      def _cat(*args, &block) # :nodoc:
        capture { cat(*args, &block) }
      end
      
      def cd(dir=nil)
        if block_given?
          var = next_variable_name('cd')
          target.puts %{#{var}=$(pwd)}
        end
      
        execute "cd", dir
      
        if block_given?
          yield
          execute "cd", "$#{var}"
        end
        chain_proxy
      end
      
      def _cd(*args, &block) # :nodoc:
        capture { cd(*args, &block) }
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
        capture { chmod(*args, &block) }
      end
      
      # Makes a command to chown a file or directory.
      def chown(user, group, target)
        if user || group
          execute 'chown', "#{user}:#{group}", target
        end
        chain_proxy
      end
      
      def _chown(*args, &block) # :nodoc:
        capture { chown(*args, &block) }
      end
      
      # Copy source to target.  Accepts a hash of command line options.
      def cp(source, target, options={})
        execute 'cp', source, target, options
        chain_proxy
      end
      
      def _cp(*args, &block) # :nodoc:
        capture { cp(*args, &block) }
      end
      
      # Copy source to target, with -f.
      def cp_f(source, target)
        cp source, target, '-f' => true
        chain_proxy
      end
      
      def _cp_f(*args, &block) # :nodoc:
        capture { cp_f(*args, &block) }
      end
      
      # Copy source to target, with -r.
      def cp_r(source, target)
        cp source, target, '-r'=> true
        chain_proxy
      end
      
      def _cp_r(*args, &block) # :nodoc:
        capture { cp_r(*args, &block) }
      end
      
      # Copy source to target, with -rf.
      def cp_rf(source, target)
        cp source, target, '-rf' => true
        chain_proxy
      end
      
      def _cp_rf(*args, &block) # :nodoc:
        capture { cp_rf(*args, &block) }
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
        capture { date(*args, &block) }
      end
      
      def directory?(path)
        #  [ -d "<%= path %>" ]
        _erbout.concat "[ -d \""; _erbout.concat(( path ).to_s); _erbout.concat "\" ]";
        chain_proxy
      end
      
      def _directory?(*args, &block) # :nodoc:
        capture { directory?(*args, &block) }
      end
      
      # Echo the args.
      def echo(*args)
        execute 'echo', *args
        chain_proxy
      end
      
      def _echo(*args, &block) # :nodoc:
        capture { echo(*args, &block) }
      end
      
      def exists?(path)
        #  [ -e "<%= path %>" ]
        _erbout.concat "[ -e \""; _erbout.concat(( path ).to_s); _erbout.concat "\" ]";
        chain_proxy
      end
      
      def _exists?(*args, &block) # :nodoc:
        capture { exists?(*args, &block) }
      end
      
      def file?(path)
        #  [ -f "<%= path %>" ]
        _erbout.concat "[ -f \""; _erbout.concat(( path ).to_s); _erbout.concat "\" ]";
        chain_proxy
      end
      
      def _file?(*args, &block) # :nodoc:
        capture { file?(*args, &block) }
      end
      
      # Link source to target.  Accepts a hash of command line options.
      def ln(source, target, options={})
        execute 'ln', source, target, options
        chain_proxy
      end
      
      def _ln(*args, &block) # :nodoc:
        capture { ln(*args, &block) }
      end
      
      # Copy source to target, with -s.
      def ln_s(source, target)
        ln source, target, '-s' => true
        chain_proxy
      end
      
      def _ln_s(*args, &block) # :nodoc:
        capture { ln_s(*args, &block) }
      end
      
      # Make a directory.  Accepts a hash of command line options.
      def mkdir(path, options={})
        execute 'mkdir', path, options
        chain_proxy
      end
      
      def _mkdir(*args, &block) # :nodoc:
        capture { mkdir(*args, &block) }
      end
      
      # Make a directory, and parent directories as needed.
      def mkdir_p(path)
        mkdir path, '-p' => true
        chain_proxy
      end
      
      def _mkdir_p(*args, &block) # :nodoc:
        capture { mkdir_p(*args, &block) }
      end
      
      # Move source to target.  Accepts a hash of command line options.
      def mv(source, target, options={})
        execute 'mv', source, target, options
        chain_proxy
      end
      
      def _mv(*args, &block) # :nodoc:
        capture { mv(*args, &block) }
      end
      
      # Move source to target, with -f.
      def mv_f(source, target)
        mv source, target, '-f' => true
        chain_proxy
      end
      
      def _mv_f(*args, &block) # :nodoc:
        capture { mv_f(*args, &block) }
      end
      
      # Unlink a file.  Accepts a hash of command line options.
      def rm(path, options={})
        execute 'rm', path, options
        chain_proxy
      end
      
      def _rm(*args, &block) # :nodoc:
        capture { rm(*args, &block) }
      end
      
      # Unlink a file or directory, with -r.
      def rm_r(path)
        rm path, '-r' => true
        chain_proxy
      end
      
      def _rm_r(*args, &block) # :nodoc:
        capture { rm_r(*args, &block) }
      end
      
      # Unlink a file or directory, with -rf.
      def rm_rf(path)
        rm path, '-rf' => true
        chain_proxy
      end
      
      def _rm_rf(*args, &block) # :nodoc:
        capture { rm_rf(*args, &block) }
      end
      
      def section(comment="")
        n = (78 - comment.length)/2
        str = "-" * n
        #  #<%= str %><%= comment %><%= str %><%= "-" if comment.length % 2 == 1 %>
        #  
        _erbout.concat "#"; _erbout.concat(( str ).to_s); _erbout.concat(( comment ).to_s); _erbout.concat(( str ).to_s); _erbout.concat(( "-" if comment.length % 2 == 1 ).to_s); _erbout.concat "\n"
        chain_proxy
      end
      
      def _section(*args, &block) # :nodoc:
        capture { section(*args, &block) }
      end
      
      # Sets the options to on (true) or off (false) as specified.  If a block is
      # given then options will only be reset when the block completes.
      def set(options)
        if block_given?
          var = next_variable_name('set')
          patterns = options.keys.collect {|key| "-e #{key}" }.sort
          target.puts %{#{var}=$(set +o | grep #{patterns.join(' ')})}
        end
      
        super
      
        if block_given?
          yield
          target.puts %{eval "$#{var}"}
        end
        chain_proxy
      end
      
      def _set(*args, &block) # :nodoc:
        capture { set(*args, &block) }
      end
      
      # Sets the system time.  Must be root for this to succeed.
      def set_date(time=Time.now) 
        #  date -u <%= time.dup.utc.strftime("%m%d%H%M%Y.%S") %>
        #  <% check_status %>
        _erbout.concat "date -u "; _erbout.concat(( time.dup.utc.strftime("%m%d%H%M%Y.%S") ).to_s); _erbout.concat "\n"
        check_status ;
        chain_proxy
      end
      
      def _set_date(*args, &block) # :nodoc:
        capture { set_date(*args, &block) }
      end
      
      def shebang(program='/bin/sh', options={})
        #  #!<%= program %>
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
        _erbout.concat "#!"; _erbout.concat(( program ).to_s); _erbout.concat "\n"
        section 
        _erbout.concat "\n"
        _erbout.concat "usage=\"usage: %s: [-h]\\n\"\n"
        _erbout.concat "while getopts \"h\" opt\n"
        _erbout.concat "do\n"
        _erbout.concat "  case $opt in\n"
        _erbout.concat "  h  )  printf \"$usage\" $0\n"
        _erbout.concat "        printf \"       %s   %s\\n\" \"-h\" \"prints this help\"\n"
        _erbout.concat "        exit 0 ;;\n"
        _erbout.concat "  \\? )  printf \"$usage\" $0\n"
        _erbout.concat "        exit 2 ;;\n"
        _erbout.concat "  esac\n"
        _erbout.concat "done\n"
        _erbout.concat "shift $(($OPTIND - 1))\n"
        _erbout.concat "\n"
        check_status_function 
        yield if block_given? 
        _erbout.concat "\n"
        if options[:info] 
        _erbout.concat "echo >&2\n"
        _erbout.concat "echo \"###############################################################################\" >&2\n"
        _erbout.concat "echo \"# $(whoami)@$(hostname):$(pwd):$0\" >&2\n"
        _erbout.concat "\n"
        end 
        section " #{target_name} " 
        _erbout.concat "\n"
        chain_proxy
      end
      
      def _shebang(*args, &block) # :nodoc:
        capture { shebang(*args, &block) }
      end
    end
  end
end
