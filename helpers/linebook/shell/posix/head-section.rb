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

def outdent_ids
  @outdent_ids ||= []
end

# Indents the output of the block.  See current_indent.
def indent(indent='  ', &block)
  @current_indent = current_indent + indent
  str = capture(&block)
  @current_indent.chomp! indent
  
  unless str.empty?
    str.gsub!(/^/, indent)
    
    if current_indent.empty?
      outdent_ids.each do |id|
        str.gsub!(/#{id}(\d+):(.*?)#{id}/m) do
          $2.gsub!(/^.{#{$1.to_i}}/, '')
        end
      end
      outdent_ids.clear
    end
    
    target.puts str
  end
  
  self
end

# Outdents a section of text indented by indent.
def outdent(id=nil)
  if current_indent.empty?
    yield
  else
    id ||= ":outdent_#{outdent_ids.length}:"
    outdent_ids << id
    
    target << "#{id}#{current_indent.length}:#{rstrip}"
    yield
    target << "#{id}#{rstrip}"
  end
  
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
