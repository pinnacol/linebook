Installs a package using apt-get.
(name, version=nil, options={:q => true, :y => true})
--
  name = "#{name}=#{version}" unless version.to_s.strip.empty?
  execute "apt-get install", name, options
  