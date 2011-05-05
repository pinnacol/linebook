require 'linebook/os/posix'
include Posix

def guess_target_name(source_name)
  target_dir  = File.dirname(target_name)
  name = File.basename(source_name)
  
  _package_.next_target_name(target_dir == '.' ? name : File.join(target_dir, name))
end

def close
  unless closed? 
    if @shebang ||= false
      section " (#{target_name}) "
    end
  end
  
  super
end

def trailer
  /(\s*(?:\ncheck_status.*?\n\s*)?)\z/
end
