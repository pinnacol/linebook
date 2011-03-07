require 'erb'

# Generated by Linecook, do not edit.
module Linebook
  module Os
    module Unix
      require 'linebook/os/posix'
      include Posix
      
      def shell_path
        @shell_path ||= '/bin/sh'
      end
      
      def env_path
        @env_path ||= '/usr/bin/env'
      end
      
      def target_format
        @target_format ||= "$(pwd)/%s"
      end
      
      def target_path(target_name)
        target_format % super(target_name)
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
        self
      end
      
      def _cat(*args, &block) # :nodoc:
        capture { cat(*args, &block) }
      end
      
      # Makes a command to chmod a file or directory.  Provide the mode as the
      # literal string that should go into the statement:
      # 
      #   chmod "600" target
      def chmod(mode, target)
        if mode
          execute 'chmod', mode, target
        end
        self
      end
      
      def _chmod(*args, &block) # :nodoc:
        capture { chmod(*args, &block) }
      end
      
      # Makes a command to chown a file or directory.
      def chown(user, group, target)
        if user || group
          execute 'chown', "#{user}:#{group}", target
        end
        self
      end
      
      def _chown(*args, &block) # :nodoc:
        capture { chown(*args, &block) }
      end
      
      # Copy source to target.  Accepts a hash of command line options.
      def cp(source, target, options={})
        execute 'cp', source, target, options
        self
      end
      
      def _cp(*args, &block) # :nodoc:
        capture { cp(*args, &block) }
      end
      
      # Copy source to target, with -f.
      def cp_f(source, target)
        cp source, target, '-f' => true
        self
      end
      
      def _cp_f(*args, &block) # :nodoc:
        capture { cp_f(*args, &block) }
      end
      
      # Copy source to target, with -r.
      def cp_r(source, target)
        cp source, target, '-r'=> true
        self
      end
      
      def _cp_r(*args, &block) # :nodoc:
        capture { cp_r(*args, &block) }
      end
      
      # Copy source to target, with -rf.
      def cp_rf(source, target)
        cp source, target, '-rf' => true
        self
      end
      
      def _cp_rf(*args, &block) # :nodoc:
        capture { cp_rf(*args, &block) }
      end
      
      # Returns the current system time.  A format string may be provided, as well as
      # a hash of command line options.
      def date(format=nil, options={})
        if format
          format = quote("+#{format}")
        end
        
        execute "date", format, options
        self
      end
      
      def _date(*args, &block) # :nodoc:
        capture { date(*args, &block) }
      end
      
      def directory?(path)
        #  [ -d "<%= path %>" ]
        _erbout.concat "[ -d \""; _erbout.concat(( path ).to_s); _erbout.concat "\" ]";
        self
      end
      
      def _directory?(*args, &block) # :nodoc:
        capture { directory?(*args, &block) }
      end
      
      # Echo the args.
      def echo(*args)
        #  echo '<%= args.join(' ') %>'
        #  
        _erbout.concat "echo '"; _erbout.concat(( args.join(' ') ).to_s); _erbout.concat "'\n"
        self
      end
      
      def _echo(*args, &block) # :nodoc:
        capture { echo(*args, &block) }
      end
      
      def exists?(path)
        #  [ -e "<%= path %>" ]
        _erbout.concat "[ -e \""; _erbout.concat(( path ).to_s); _erbout.concat "\" ]";
        self
      end
      
      def _exists?(*args, &block) # :nodoc:
        capture { exists?(*args, &block) }
      end
      
      def file?(path)
        #  [ -f "<%= path %>" ]
        _erbout.concat "[ -f \""; _erbout.concat(( path ).to_s); _erbout.concat "\" ]";
        self
      end
      
      def _file?(*args, &block) # :nodoc:
        capture { file?(*args, &block) }
      end
      
      # Link source to target.  Accepts a hash of command line options.
      def ln(source, target, options={})
        execute 'ln', source, target, options
        self
      end
      
      def _ln(*args, &block) # :nodoc:
        capture { ln(*args, &block) }
      end
      
      # Copy source to target, with -s.
      def ln_s(source, target)
        ln source, target, '-s' => true
        self
      end
      
      def _ln_s(*args, &block) # :nodoc:
        capture { ln_s(*args, &block) }
      end
      
      # Make a directory.  Accepts a hash of command line options.
      def mkdir(path, options={})
        execute 'mkdir', path, options
        self
      end
      
      def _mkdir(*args, &block) # :nodoc:
        capture { mkdir(*args, &block) }
      end
      
      # Make a directory, and parent directories as needed.
      def mkdir_p(path)
        mkdir path, '-p' => true
        self
      end
      
      def _mkdir_p(*args, &block) # :nodoc:
        capture { mkdir_p(*args, &block) }
      end
      
      # Move source to target.  Accepts a hash of command line options.
      def mv(source, target, options={})
        execute 'mv', source, target, options
        self
      end
      
      def _mv(*args, &block) # :nodoc:
        capture { mv(*args, &block) }
      end
      
      # Move source to target, with -f.
      def mv_f(source, target)
        mv source, target, '-f' => true
        self
      end
      
      def _mv_f(*args, &block) # :nodoc:
        capture { mv_f(*args, &block) }
      end
      
      def quiet()
        #  set +x +v<% if block_given? %>
        #  <% indent { yield } %>
        #  set $LINECOOK_OPTS > /dev/null<% end %>
        #  
        #  
        _erbout.concat "set +x +v";  if block_given? ; _erbout.concat "\n"
        indent { yield } 
        _erbout.concat "set $LINECOOK_OPTS > /dev/null";  end ; _erbout.concat "\n"
        _erbout.concat "\n"
        self
      end
      
      def _quiet(*args, &block) # :nodoc:
        capture { quiet(*args, &block) }
      end
      
      # Unlink a file.  Accepts a hash of command line options.
      def rm(path, options={})
        execute 'rm', path, options
        self
      end
      
      def _rm(*args, &block) # :nodoc:
        capture { rm(*args, &block) }
      end
      
      # Unlink a file or directory, with -r.
      def rm_r(path)
        rm path, '-r' => true
        self
      end
      
      def _rm_r(*args, &block) # :nodoc:
        capture { rm_r(*args, &block) }
      end
      
      # Unlink a file or directory, with -rf.
      def rm_rf(path)
        rm path, '-rf' => true
        self
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
        self
      end
      
      def _section(*args, &block) # :nodoc:
        capture { section(*args, &block) }
      end
      
      # Sets the system time.  Must be root for this to succeed.
      def set_date(time=Time.now) 
        #  date -u <%= time.dup.utc.strftime("%m%d%H%M%Y.%S") %>
        #  <% check_status %>
        _erbout.concat "date -u "; _erbout.concat(( time.dup.utc.strftime("%m%d%H%M%Y.%S") ).to_s); _erbout.concat "\n"
        check_status ;
        self
      end
      
      def _set_date(*args, &block) # :nodoc:
        capture { set_date(*args, &block) }
      end
      
      # == Notes
      # Use dev/null on set such that no options will not dump ENV into stdout.
      def shebang(options={})
        @target_format = '$LINECOOK_DIR/%s'
        #  #! <%= shell_path %>
        #  <% section %>
        #  <% check_status_function %>
        #  
        #  export LINECOOK_DIR=${LINECOOK_DIR:-$(cd $(dirname $0); pwd)}
        #  export LINECOOK_OPTS=${LINECOOK_OPTS:--v}
        #  
        #  usage="usage: %s: [-hqvx]\n"
        #  option="       %s   %s\n"
        #  while getopts "hqvx" opt
        #  do
        #    case $opt in
        #    h  )  printf "$usage" $0
        #          printf "$option" "-h" "prints this help"
        #          printf "$option" "-q" "quiet (set +v +x)"
        #          printf "$option" "-v" "verbose (set -v)"
        #          printf "$option" "-x" "xtrace (set -x)"
        #          exit 0 ;;
        #    q  )  LINECOOK_OPTS="$LINECOOK_OPTS +v +x";;
        #    v  )  LINECOOK_OPTS="$LINECOOK_OPTS -v";;
        #    x  )  LINECOOK_OPTS="$LINECOOK_OPTS -x";;
        #    \? )  printf "$usage" $0
        #          exit 2 ;;
        #    esac
        #  done
        #  shift $(($OPTIND - 1))
        #  
        #  <% if options[:info] %>
        #  echo >&2
        #  echo "###############################################################################" >&2
        #  echo "# $SHELL" >&2
        #  echo "# $(whoami)@$(hostname):$(pwd)" >&2
        #  
        #  <% end %>
        #  set $LINECOOK_OPTS > /dev/null
        #  <% section " #{target_name} " %>
        #  
        #  
        _erbout.concat "#! "; _erbout.concat(( shell_path ).to_s); _erbout.concat "\n"
        section 
        check_status_function 
        _erbout.concat "\n"
        _erbout.concat "export LINECOOK_DIR=${LINECOOK_DIR:-$(cd $(dirname $0); pwd)}\n"
        _erbout.concat "export LINECOOK_OPTS=${LINECOOK_OPTS:--v}\n"
        _erbout.concat "\n"
        _erbout.concat "usage=\"usage: %s: [-hqvx]\\n\"\n"
        _erbout.concat "option=\"       %s   %s\\n\"\n"
        _erbout.concat "while getopts \"hqvx\" opt\n"
        _erbout.concat "do\n"
        _erbout.concat "  case $opt in\n"
        _erbout.concat "  h  )  printf \"$usage\" $0\n"
        _erbout.concat "        printf \"$option\" \"-h\" \"prints this help\"\n"
        _erbout.concat "        printf \"$option\" \"-q\" \"quiet (set +v +x)\"\n"
        _erbout.concat "        printf \"$option\" \"-v\" \"verbose (set -v)\"\n"
        _erbout.concat "        printf \"$option\" \"-x\" \"xtrace (set -x)\"\n"
        _erbout.concat "        exit 0 ;;\n"
        _erbout.concat "  q  )  LINECOOK_OPTS=\"$LINECOOK_OPTS +v +x\";;\n"
        _erbout.concat "  v  )  LINECOOK_OPTS=\"$LINECOOK_OPTS -v\";;\n"
        _erbout.concat "  x  )  LINECOOK_OPTS=\"$LINECOOK_OPTS -x\";;\n"
        _erbout.concat "  \\? )  printf \"$usage\" $0\n"
        _erbout.concat "        exit 2 ;;\n"
        _erbout.concat "  esac\n"
        _erbout.concat "done\n"
        _erbout.concat "shift $(($OPTIND - 1))\n"
        _erbout.concat "\n"
        if options[:info] 
        _erbout.concat "echo >&2\n"
        _erbout.concat "echo \"###############################################################################\" >&2\n"
        _erbout.concat "echo \"# $SHELL\" >&2\n"
        _erbout.concat "echo \"# $(whoami)@$(hostname):$(pwd)\" >&2\n"
        _erbout.concat "\n"
        end 
        _erbout.concat "set $LINECOOK_OPTS > /dev/null\n"
        section " #{target_name} " 
        _erbout.concat "\n"
        self
      end
      
      def _shebang(*args, &block) # :nodoc:
        capture { shebang(*args, &block) }
      end
      
      def verbose()
        #  set -v<% if block_given? %>
        #  <% indent { yield } %>
        #  set $LINECOOK_OPTS > /dev/null<% end %>
        #  
        #  
        _erbout.concat "set -v";  if block_given? ; _erbout.concat "\n"
        indent { yield } 
        _erbout.concat "set $LINECOOK_OPTS > /dev/null";  end ; _erbout.concat "\n"
        _erbout.concat "\n"
        self
      end
      
      def _verbose(*args, &block) # :nodoc:
        capture { verbose(*args, &block) }
      end
      
      def xtrace()
        #  set -x<% if block_given? %>
        #  <% indent { yield } %>
        #  set $LINECOOK_OPTS > /dev/null<% end %>
        #  
        #  
        _erbout.concat "set -x";  if block_given? ; _erbout.concat "\n"
        indent { yield } 
        _erbout.concat "set $LINECOOK_OPTS > /dev/null";  end ; _erbout.concat "\n"
        _erbout.concat "\n"
        self
      end
      
      def _xtrace(*args, &block) # :nodoc:
        capture { xtrace(*args, &block) }
      end
    end
  end
end
