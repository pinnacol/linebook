def quote(arg)
  "\"#{arg}\""
end

def blank?(obj)
  obj.nil? || obj.to_s.strip.empty?
end

def nest_opts(opts, default={})
  opts = default if opts.nil? || opts == true
  opts && block_given? ? yield(opts) : opts
end

attr_accessor :cmd_prefix

def with_cmd_prefix(prefix)
  current = cmd_prefix
  begin
    self.cmd_prefix = prefix
    yield
  ensure
    self.cmd_prefix = current
  end
end

attr_accessor :cmd_suffix

def with_cmd_suffix(suffix)
  current = cmd_suffix
  begin
    self.cmd_suffix = suffix
    yield
  ensure
    self.cmd_suffix = current
  end
end
