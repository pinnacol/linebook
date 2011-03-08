
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

# Returns true if the str is not an option, and is not already quoted (either
# by quotes or apostrophes).  The intention is to check whether a string
# _should_ be quoted.
def quote?(str)
  str[0] == ?- || str[0] == ?+ || quoted?(str) ? false : true
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
# * Prepend '--' to mulit-char keys and '-' to single-char keys (unless
#   they already start with '-').
# * For true values return the '--key'
# * For false/nil values return nothing
# * For all other values, quote (unless already quoted) and return '--key
#  "value"'
#
# In addition, key formatting is performed on non-string keys (typically
# symbols) such that underscores are converted to dashes, ie :some_key =>
# 'some-key'.
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
