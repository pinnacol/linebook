Installs a file
(source, target, options={})
--
  nest_opts(options[:backup], :mv => true) do |opts|
    if_ _file?(target) do
      backup target, opts
    end
  end
  
  nest_opts(options[:directory]) do |opts|
    directory File.dirname(target), opts
  end
  
  cp source, target
  chmod options[:mode] || 644, target
  chown options[:user], options[:group], target
