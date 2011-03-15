def self.extended(base)
  base.attributes 'linebook/shell'
  
  if os = base.attrs['linebook']['os']
    base.helpers os
  end
  
  if shell = base.attrs['linebook']['shell']
    base.helpers shell
  end
  
  super
end

def log_dir
  '/var/log/linecook'
end
