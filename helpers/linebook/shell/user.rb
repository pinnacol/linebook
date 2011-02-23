(name, options={})
--
  not_if _user?(name) do
    adduser name
  end
  
  groups = options[:groups]
  if groups && !groups.empty?
    usermod name, :groups => "#{groups.join(',')},$(#{_groups(name, :sep => ',')})"
  end