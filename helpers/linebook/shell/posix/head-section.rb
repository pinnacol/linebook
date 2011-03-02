
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

def nest_opts(opts, default={})
  opts = default if opts.nil? || opts == true
  opts && block_given? ? yield(opts) : opts
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
