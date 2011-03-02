
# Encloses the arg in quotes ("").
def quote(arg)
  "\"#{arg}\""
end

# Returns true if the arg is not an option, and is not already quoted (either
# by quotes or apostrophes).  The intention is to check whether an arg
# _should_ be quoted.
def quote?(arg)
  arg[0] == ?- || quoted?(arg) ? false : true
end

# Returns true if the arg is quoted (either by quotes or apostrophes).
def quoted?(arg)
  arg =~ /\A".*"\z/ || arg =~ /\A'.*'\z/ ? true : false
end

# Returns true if the obj converts to a string which is whitespace or empty.
def blank?(obj)
  # shortcut for nil...
  obj.nil? || obj.to_s.strip.empty?
end

# The prefix added to all cmd calls.
attr_accessor :cmd_prefix

# Sets cmd_prefix for the duration of a block.
def with_cmd_prefix(prefix)
  current = cmd_prefix
  begin
    self.cmd_prefix = prefix
    yield
  ensure
    self.cmd_prefix = current
  end
end

# The suffix added to all cmd calls.
attr_accessor :cmd_suffix

# Sets cmd_suffix for the duration of a block.
def with_cmd_suffix(suffix)
  current = cmd_suffix
  begin
    self.cmd_suffix = suffix
    yield
  ensure
    self.cmd_suffix = current
  end
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
def format_cmd_options(opts)
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
      value = value.to_s
      
      unless quoted?(value) || !quote?(value)
        value = quote(value)
      end
      
      options << "#{key} #{value}"
    end
  end
  
  options.sort
end
