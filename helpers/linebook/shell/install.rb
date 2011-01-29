Installs a file
(source, target, options={})
--
  nest_opts(options[:backup], :mv => true) do |opts|
    only_if _file?(target) do
      backup target, opts
    end
  end
  
  nest_opts(options[:directory]) do |opts|
    directory File.dirname(target), opts
  end
  
  cp source, target
  chmod options[:mode], target
  chown options[:user], options[:group], target
