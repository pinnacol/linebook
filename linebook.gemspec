$:.unshift File.expand_path('../lib', __FILE__)
require 'linebook/version'
$:.shift

Gem::Specification.new do |s|
  s.name = 'linebook'
  s.version = Linebook::VERSION
  s.author  = 'Simon Chiang'
  s.email   = 'simon.chiang@pinnacol.com'
  s.summary = ''
  s.homepage = 'http://gems.pinnacol.com/linebook'
  s.rubyforge_project = ''
  s.require_path = 'lib'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.rdoc_options.concat %W{--main README -S -N --title Linebook}
  
  # add dependencies
  # s.add_dependency('x', '= 1.0')
  
  # list extra rdoc files here.
  s.extra_rdoc_files = %W{
    History
    README
  }
  
  # list the files you want to include here.
  s.files = %W{
  }
end