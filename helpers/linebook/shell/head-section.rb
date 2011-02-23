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

def format_opts(opts)
  options = opts.collect do |(key, value)|
    unless key.kind_of?(String)
      key = key.to_s.gsub('_', '-')
    end
    
    prefix = key.length == 1 ? '-' : '--'
    
    case value
    when true
      "#{prefix}#{key}"
    when false, nil
      nil
    else
      %{#{prefix}#{key} "#{value}"}
    end
  end
  
  options.compact.sort
end
