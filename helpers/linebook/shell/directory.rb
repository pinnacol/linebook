(target, options={})
--
  not_if _directory?(target) do 
    mkdir_p target
  end 
  chmod options[:mode] || 755, target
  chown options[:user], options[:group], target