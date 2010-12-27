$:.unshift File.expand_path('../lib', __FILE__)
require 'linebook/version'
$:.shift

Gem::Specification.new do |s|
  s.name     = 'linebook'
  s.version  = Linebook::VERSION
  s.platform = Gem::Platform::RUBY
  s.author   = 'Simon Chiang'
  s.email    = 'simon.a.chiang@gmail.com'
  s.homepage = 'http://rubygems.org/gems/linebook'
  s.summary  = 'Cookbooks for Linecook'
  s.description = 'Linebook is a distribution module used by Linecook.'

  s.rubyforge_project = ''
  s.require_path = 'lib'
  s.has_rdoc = true
  s.rdoc_options.concat %W{--main README -S -N --title Linebook}
  
  # list extra rdoc files here.
  s.extra_rdoc_files = %W{
    History
    README
    License.txt
  }
  
  # list the files you want to include here.
  s.files = %W{
    lib/linebook.rb
    lib/linebook/version.rb
  }
end