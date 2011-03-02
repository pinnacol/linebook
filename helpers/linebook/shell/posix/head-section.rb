
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

# An array used for tracking indents currently in use.
def indents
  @indents ||= []
end

# Indents the output of the block.  Indents may be nested. To prevent a
# section from being indented, enclose it within outdent which resets
# indentation to nothing for the duration of a block.
#
# Example:
#
#   target.puts 'a'
#   indent do
#     target.puts 'b'
#     outdent do
#       target.puts 'c'
#       indent do
#         target.puts 'd'
#       end
#       target.puts 'c'
#     end
#     target.puts 'b'
#   end
#   target.puts 'a'
#
#   "\n" + result
#   # => %q{
#   # a
#   #   b
#   # c
#   #   d
#   # c
#   #   b
#   # a
#   # }
#
def indent(indent='  ', &block)
  indents << indents.last.to_s + indent
  str = capture(&block)
  indents.pop
  
  unless str.empty?
    str.gsub!(/^/, indent)
    
    if indents.empty?
      outdents.each do |flag|
        str.gsub!(/#{flag}(\d+):(.*?)#{flag}/m) do
          $2.gsub!(/^.{#{$1.to_i}}/, '')
        end
      end
      outdents.clear
    end
    
    target.puts str
  end
  
  self
end

# An array used for tracking outdents currently in use.
def outdents
  @outdents ||= []
end

# Resets indentation to nothing for a section of text indented by indent.
#
# === Notes
#
# Outdent works by setting a text flag around the outdented section; the flag
# and indentation is later stripped out using regexps.  For that reason, be
# sure flag is not something that will appear anywhere else in the section.
#
# The default flag is like ':outdent_N:' where N is a big random number.
def outdent(flag=nil)
  current_indent = indents.last
  
  if current_indent.nil?
    yield
  else
    flag ||= ":outdent_#{rand(10000000)}:"
    outdents << flag
    
    target << "#{flag}#{current_indent.length}:#{rstrip}"
    indents << ''
    
    yield
    
    indents.pop
    target << "#{flag}#{rstrip}"
  end
  
  self
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
