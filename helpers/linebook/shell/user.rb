(name, options={})
--
  unless_ _user?(name) do
    useradd name
  end
  
  
  if groups = options[:groups]
    groups = groups.gsub('*') { "$(#{_groups(name, :sep => ',')})" }
    usermod name, :groups => groups
  end