(target, options={})
--
  not_if _directory?(target) do 
    mkdir_p target
  end 
  chmod options[:mode], target
  chown options[:user], options[:group], target