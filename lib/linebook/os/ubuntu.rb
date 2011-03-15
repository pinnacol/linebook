require 'erb'

module Linebook
  module Os
    module Ubuntu
      require 'linebook/os/linux'
      include Linux
      
      # Installs a package using apt-get.
      def package(name, version=nil, options={:q => true, :y => true})
        name = "#{name}=#{version}" unless blank?(version)
        execute "apt-get install", name, options
        chain_proxy
      end
      
      def _package(*args, &block) # :nodoc:
        str = capture_block { package(*args, &block) }
        str.strip!
        str
      end
    end
  end
end
