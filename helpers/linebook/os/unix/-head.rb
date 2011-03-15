require 'linebook/os/posix'
include Posix

def guess_target_name(source_name)
  _package_.next_target_name File.join("#{target_name}.d", File.basename(source_name))
end

def close
  unless closed? 
    if @shebang ||= false
      section " (#{target_name}) "
    end
  end
  
  super
end
