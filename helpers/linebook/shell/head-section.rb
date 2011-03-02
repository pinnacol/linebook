require 'linebook/shell/unix'
include Unix

def self.extended(base)
  base.attributes 'linebook/shell'
  
  if shell = base.attrs['linebook']['shell']
    base.helpers shell
  end
  
  if os = base.attrs['linebook']['os']
    base.helpers os
  end
  
  super
end

def guess_target_name(source_name)
  next_target_name File.join("#{target_name}.d", File.basename(source_name))
end

def log_dir
  '/var/log/linecook'
end

def nest_opts(opts, default={})
  opts = default if opts.nil? || opts == true
  opts && block_given? ? yield(opts) : opts
end
