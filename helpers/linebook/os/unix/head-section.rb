require 'linebook/os/posix'
include Posix

def shell_path
  @shell_path ||= '/bin/sh'
end

def env_path
  @env_path ||= '/usr/bin/env'
end

def target_format
  @target_format ||= "%s"
end

def target_path(target_name)
  target_format % super(target_name)
end

def close
  unless closed?
    section " (#{target_name}) "
  end
  
  super
end
