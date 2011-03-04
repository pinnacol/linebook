require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/shell'
require 'linebook/os/ubuntu'

class UbuntuTest < Test::Unit::TestCase
  include Linecook::Test
  only_hosts 'ubuntu'
  
  def setup
    super
    use_helpers Linebook::Shell, Linebook::Os::Ubuntu
  end
  
  #
  # package test
  #
  
  def test_package_creates_commands_to_install_package_with_apt_get
    assert_recipe %q{
      sudo apt-get -q -y install name
    } do
      package 'name'
    end
  end
  
  def test_package_adds_version_request_if_specified
    assert_recipe %q{
      sudo apt-get -q -y install name=1.0.0
    } do
      package 'name', '1.0.0'
    end
  end
end