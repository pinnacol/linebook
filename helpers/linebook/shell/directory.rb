(target, options={})
--
  unless_ _directory?(target) do 
    mkdir '-p', target
  end 
  chmod options[:mode] || 0755, target
  chown options[:owner], options[:group], target