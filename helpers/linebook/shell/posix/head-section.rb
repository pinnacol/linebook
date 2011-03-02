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

# Returns the current indentation string.
def current_indent
  @current_indent ||= ""
end

# Indents the output of the block.  See current_indent.
def indent(indent='  ', &block)
  @current_indent = current_indent + indent
  
  str = capture(&block)
  
  unless str.empty?
    str.gsub!(/^/, indent)
    target.puts str
  end
  
  @current_indent.chomp! indent
  self
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
