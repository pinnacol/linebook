Installs a package using apt-get.
(name, version=nil, options={:q => true, :y => true})
--
  name = "#{name}=#{version}" unless blank?(version)
  execute "apt-get install", name, options
  