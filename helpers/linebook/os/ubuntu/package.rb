Installs a package using apt-get, by default with the options '-q -y'.
(name, version=nil, options={})
--
  name = "#{name}=#{version}" unless blank?(version)
  execute "apt-get install", name, {:q => true, :y => true}.merge(options)
  