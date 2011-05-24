require 'rubygems'
require 'bundler'
Bundler.setup

require 'test/unit'
require 'linecook/test'

if name = ENV['NAME']
  ARGV << "--name=#{name}"
end
