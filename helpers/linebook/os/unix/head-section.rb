require 'linebook/os/posix'
include Posix

def shell_path
  @shell_path ||= '/bin/sh'
end

def env_path
  @env_path ||= '/usr/bin/env'
end

def guess_target_name(source_name)
  next_target_name File.join("#{target_name}.d", File.basename(source_name))
end

def close
  unless closed?
    section " (#{target_name}) "
  end
  
  super
end
