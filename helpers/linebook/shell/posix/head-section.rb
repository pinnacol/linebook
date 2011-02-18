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
