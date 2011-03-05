require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/linux'

class LinuxTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Linux
  end
  
  TEST_USER  = 'test_user'
  TEST_GROUP = 'test_group'
  
  def clean_recipe
    setup_recipe do
      path = capture_path('cleanup_test_user.sh') do 
        target.puts %{userdel #{TEST_USER} > /dev/null 2>&1}
        target.puts %{groupdel #{TEST_GROUP} > /dev/null 2>&1}
      end
      
      target.puts "su root '#{path}'"
      target.puts "true"
    end
  end
  
  #
  # useradd test
  #
  
  def test_useradd_adds_user
    clean_recipe
    
    setup_recipe do
      target.puts "id #{TEST_USER} 2>&1"
      useradd TEST_USER
      target.puts "id -nu #{TEST_USER}"
    end
    
    assert_output_equal %{
      id: #{TEST_USER}: No such user
      #{TEST_USER}
    }, *run_package
  end
  
  # #
  # # su test
  # #
  # 
  # def test_su_switches_user_for_duration_of_a_block
  #   setup_recipe do
  #     su 'root' do
  #       target.puts 'whoami'
  #     end
  #     
  #     target.puts 'if ! [ -e file ]; then echo success; fi'
  #   end
  # 
  #   assert_output_equal %{
  #     success
  #   }, *run_package
  # end
end