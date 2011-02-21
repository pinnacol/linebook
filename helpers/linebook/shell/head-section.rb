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
