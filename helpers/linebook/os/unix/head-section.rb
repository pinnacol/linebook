require 'linebook/os/posix'
include Posix

def guess_target_name(source_name)
  next_target_name File.join("#{target_name}.d", File.basename(source_name))
end

def close
  unless closed?
    section " (#{target_name}) "
  end
  
  super
end
