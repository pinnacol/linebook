require 'linebook/shell/unix'
include Unix

def shebang
  attributes 'linebook/shell'
  
  if shell = attrs['linebook']['shell']
    helpers shell
  end
  
  if os = attrs['linebook']['os']
    helpers os
  end
  
  super
end
