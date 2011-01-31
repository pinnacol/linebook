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
