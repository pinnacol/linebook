require 'erb'

module Linebook
  module Os
    module Posix
      # Returns true if the obj converts to a string which is whitespace or empty.
      def blank?(obj)
        # shortcut for nil...
        obj.nil? || obj.to_s.strip.empty?
      end
      
      # Encloses the arg in quotes if the arg is not quoted and is quotable. 
      # Stringifies arg using to_s.
      def quote(arg)
        arg = arg.to_s
        quoted?(arg) || !quote?(arg) ? arg : "\"#{arg}\""
      end
      
      # Returns true if the str is not an option (ie it begins with - or +), and is
      # not already quoted (either by quotes or apostrophes).  The intention is to
      # check whether a string _should_ be quoted.
      def quote?(str)
        c = str[0]
        c == ?- || c == ?+ || quoted?(str) ? false : true
      end
      
      # Returns true if the str is quoted (either by quotes or apostrophes).
      def quoted?(str)
        str =~ /\A".*"\z/ || str =~ /\A'.*'\z/ ? true : false
      end
      
      # Formats a command line command.  Arguments are quoted. If the last arg is a
      # hash, then it will be formatted into options using format_options and
      # prepended to args.
      def format_cmd(command, *args)
        opts = args.last.kind_of?(Hash) ? args.pop : {}
        args.compact!
        args.collect! {|arg| quote(arg) }
        
        args = format_options(opts) + args
        args.unshift(command)
        args.join(' ')
      end
      
      # Formats a hash key-value string into command line options using the
      # following heuristics:
      #
      # * Prepend '--' to mulit-char keys and '-' to single-char keys (unless they
      #   already start with '-').
      # * For true values return the '--key'
      # * For false/nil values return nothing
      # * For all other values, quote (unless already quoted) and return '--key
      #  "value"'
      #
      # In addition, key formatting is performed on non-string keys (typically
      # symbols) such that underscores are converted to dashes, ie :some_key =>
      # 'some-key'.  Note that options are sorted, such that short options appear
      # after long options, and so should 'win' given typical option processing.
      def format_options(opts)
        options = []
        
        opts.each do |(key, value)|
          unless key.kind_of?(String)
            key = key.to_s.gsub('_', '-')
          end
          
          unless key[0] == ?-
            prefix = key.length == 1 ? '-' : '--'
            key = "#{prefix}#{key}"
          end
          
          case value
          when true
            options << key
          when false, nil
            next
          else
            options << "#{key} #{quote(value.to_s)}"
          end
        end
        
        options.sort
      end
      
      # An array of functions defined for self.
      def functions
        @functions ||= []
      end
      
      # Defines a function from the block.  The block content is indented and
      # cleaned up some to make a nice function definition.  To avoid formatting,
      # provide the body directly.
      #
      # A body and block given together raises an error. Raises an error if the
      # function is already defined with a different body.
      def function(name, body=nil, &block)
        if body && block
          raise "define functions with body or block"
        end
        
        if body.nil?
          body = "\n#{capture(false) { indent(&block) }.chomp("\n")}\n"
        end
        
        function = "#{name}() {#{body}}"
        
        if current = functions.find {|func| func.index("#{name}()") == 0 }
          if current != function
            raise "function already defined: #{name.inspect}"
          end
        end
        
        functions << function
        target.puts function
        
        name
      end
      
      DEFAULT_HANDLES = {:stdin => 0, :stdout => 1, :stderr => 2}
      
      # A hash of logical names for file handles.
      def handles
        @handles ||= DEFAULT_HANDLES.dup
      end
      
      # Assign a file descriptor.
      def assign(target, source)
        rstrip if chain?
        target = handles[target] || target
        target = nil if target == 0
        source = handles[source] || source
        #   <%= target %><<%= source.kind_of?(Fixnum) ? "&#{source}" : " #{source}" %>
        #  
        _erbout.concat " "; _erbout.concat(( target ).to_s); _erbout.concat "<"; _erbout.concat(( source.kind_of?(Fixnum) ? "&#{source}" : " #{source}" ).to_s); _erbout.concat "\n"
        chain_proxy
      end
      
      def _assign(*args, &block) # :nodoc:
        capture { assign(*args, &block) }
      end
      
      # Adds a check that ensures the last exit status is as indicated. Note that no
      # check will be added unless check_status_function is added beforehand.
      def check_status(expect_status=0, fail_status='$?')
        @check_status ||= false
        
        #  <% if @check_status %>
        #  check_status <%= expect_status %> $? <%= fail_status %> $LINENO
        #  
        #  <% end %>
        if @check_status 
        _erbout.concat "check_status "; _erbout.concat(( expect_status ).to_s); _erbout.concat " $? "; _erbout.concat(( fail_status ).to_s); _erbout.concat " $LINENO\n"
        _erbout.concat "\n"
        end ;
        chain_proxy
      end
      
      def _check_status(*args, &block) # :nodoc:
        capture { check_status(*args, &block) }
      end
      
      # Adds the check status function.
      def check_status_function()
        @check_status = true
        function 'check_status', ' if [ $2 -ne $1 ]; then echo "[$2] $0:${4:-?}"; exit $3; else return $2; fi '
        chain_proxy
      end
      
      def _check_status_function(*args, &block) # :nodoc:
        capture { check_status_function(*args, &block) }
      end
      
      # Writes a comment.
      def comment(str)
        #  # <%= str %>
        #  
        _erbout.concat "# "; _erbout.concat(( str ).to_s); _erbout.concat "\n"
        chain_proxy
      end
      
      def _comment(*args, &block) # :nodoc:
        capture { comment(*args, &block) }
      end
      
      # Executes a command and checks the output status.  Quotes all non-option args
      # that aren't already quoted. Accepts a trailing hash which will be transformed
      # into command line options.
      def execute(command, *args)
        if chain?
          rstrip
          target << ' | '
        end
        #  <%= format_cmd(command, *args) %>
        #  
        #  <% check_status %>
        _erbout.concat(( format_cmd(command, *args) ).to_s)
        _erbout.concat "\n"
        check_status ;
        chain_proxy
      end
      
      def _execute(*args, &block) # :nodoc:
        capture { execute(*args, &block) }
      end
      
      # Exports a variable.
      def export(key, value)
        #  export <%= key %>=<%= quote(value) %>
        #  
        _erbout.concat "export "; _erbout.concat(( key ).to_s); _erbout.concat "="; _erbout.concat(( quote(value) ).to_s); _erbout.concat "\n"
        chain_proxy
      end
      
      def _export(*args, &block) # :nodoc:
        capture { export(*args, &block) }
      end
      
      # Assigns stdin to the file.
      # (path
      def from()
        assign(:stdin, path)
        chain_proxy
      end
      
      def _from(*args, &block) # :nodoc:
        capture { from(*args, &block) }
      end
      
      # Makes a heredoc statement surrounding the contents of the block.  Options:
      # 
      #   delimiter   the delimiter used, by default HEREDOC_n where n increments
      #   outdent     add '-' before the delimiter
      #   quote       quotes the delimiter
      def heredoc(options={})
        if chain?
          rstrip
          target << ' '
        end
        
        delimiter = options[:delimiter] || begin
          @heredoc_count ||= -1
          "HEREDOC_#{@heredoc_count += 1}"
        end
        #  <<<%= options[:outdent] ? '-' : ' '%><%= options[:quote] ? "\"#{delimiter}\"" : delimiter %><% outdent(" # :#{delimiter}:") do %>
        #  <% yield %>
        #  <%= delimiter %><% end %>
        #  
        #  
        _erbout.concat "<<"; _erbout.concat(( options[:outdent] ? '-' : ' ').to_s); _erbout.concat(( options[:quote] ? "\"#{delimiter}\"" : delimiter ).to_s);  outdent(" # :#{delimiter}:") do ; _erbout.concat "\n"
        yield 
        _erbout.concat(( delimiter ).to_s);  end 
        _erbout.concat "\n"
        chain_proxy
      end
      
      def _heredoc(*args, &block) # :nodoc:
        capture { heredoc(*args, &block) }
      end
      
      # Executes the block when the expression evaluates to a non-zero value.
      def not_if(expression, &block)
        only_if("! #{expression}", &block)
        chain_proxy
      end
      
      def _not_if(*args, &block) # :nodoc:
        capture { not_if(*args, &block) }
      end
      
      # Executes the block when the expression evaluates to zero.
      def only_if(expression)
        #  if <%= expression %>
        #  then
        #  <% indent { yield } %>
        #  fi
        #  
        #  
        _erbout.concat "if "; _erbout.concat(( expression ).to_s); _erbout.concat "\n"
        _erbout.concat "then\n"
        indent { yield } 
        _erbout.concat "fi\n"
        _erbout.concat "\n"
        chain_proxy
      end
      
      def _only_if(*args, &block) # :nodoc:
        capture { only_if(*args, &block) }
      end
      
      # Makes a redirect statement.
      def redirect(source, target)
        rstrip if chain?
        source = handles[source] || source
        source = nil if source == 1
        target = handles[target] || target
        #   <%= source.nil? || source.kind_of?(Fixnum) ? source : "#{source} " %>><%= target.kind_of?(Fixnum) ? "&#{target}" : " #{target}" %>
        #  
        _erbout.concat " "; _erbout.concat(( source.nil? || source.kind_of?(Fixnum) ? source : "#{source} " ).to_s); _erbout.concat ">"; _erbout.concat(( target.kind_of?(Fixnum) ? "&#{target}" : " #{target}" ).to_s); _erbout.concat "\n"
        chain_proxy
      end
      
      def _redirect(*args, &block) # :nodoc:
        capture { redirect(*args, &block) }
      end
      
      # Sets the options to on (true) or off (false) as specified.
      def set(options)
        #  <% options.keys.sort_by {|opt| opt.to_s }.each do |opt| %>
        #  set <%= options[opt] ? '-' : '+' %>o <%= opt %>
        #  <% end %>
        #  
        options.keys.sort_by {|opt| opt.to_s }.each do |opt| 
        _erbout.concat "set "; _erbout.concat(( options[opt] ? '-' : '+' ).to_s); _erbout.concat "o "; _erbout.concat(( opt ).to_s); _erbout.concat "\n"
        end
        chain_proxy
      end
      
      def _set(*args, &block) # :nodoc:
        capture { set(*args, &block) }
      end
      
      # Adds a redirect of stdout to a file.
      def to(path=nil)
        redirect(:stdout, path || '/dev/null')
        chain_proxy
      end
      
      def _to(*args, &block) # :nodoc:
        capture { to(*args, &block) }
      end
      
      # Unsets a list of variables.
      def unset(*keys)
        #  <% keys.each do |key| %>
        #  unset <%= key %>
        #  <% end %>
        keys.each do |key| 
        _erbout.concat "unset "; _erbout.concat(( key ).to_s); _erbout.concat "\n"
        end ;
        chain_proxy
      end
      
      def _unset(*args, &block) # :nodoc:
        capture { unset(*args, &block) }
      end
      
      # Set a variable.
      def variable(key, value)
        #  <%= key %>=<%= quote(value) %>
        #  
        #  
        _erbout.concat(( key ).to_s); _erbout.concat "="; _erbout.concat(( quote(value) ).to_s)
        _erbout.concat "\n"
        chain_proxy
      end
      
      def _variable(*args, &block) # :nodoc:
        capture { variable(*args, &block) }
      end
    end
  end
end
