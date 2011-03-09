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
  
  def clear_test_user
    setup_recipe do
      login do
        target.puts %{userdel #{TEST_USER} > /dev/null 2>&1}
        target.puts %{groupdel #{TEST_GROUP} > /dev/null 2>&1}
      end
      target.puts "true"
    end
  end
  
  #
  # login test
  #
  
  def test_login_logs_in_as_user_for_duration_of_a_block
    setup_recipe do
      target.puts "export VAR=a"
      target.puts CONTEXT_CHECK
      login 'root' do
        target.puts CONTEXT_CHECK
        target.puts "export VAR=b"
        target.puts CONTEXT_CHECK
      end
      target.puts CONTEXT_CHECK
    end
  
    assert_output_equal %{
      linecook:/home/linecook:a
      root:/root:
      root:/root:b
      linecook:/home/linecook:a
    }, *run_package
  end
  
  def test_nested_login
    setup_recipe do
      target.puts "export VAR=a"
      target.puts CONTEXT_CHECK
      login 'root' do
        target.puts CONTEXT_CHECK
        target.puts "export VAR=b"
        target.puts CONTEXT_CHECK
        login 'linecook' do
          target.puts CONTEXT_CHECK
          target.puts "export VAR=c"
          target.puts CONTEXT_CHECK
        end
        target.puts CONTEXT_CHECK
      end
      target.puts CONTEXT_CHECK
    end
  
    assert_output_equal %{
      linecook:/home/linecook:a
      root:/root:
      root:/root:b
      linecook:/home/linecook:
      linecook:/home/linecook:c
      root:/root:b
      linecook:/home/linecook:a
    }, *run_package
  end
  
  #
  # su test
  #
  
  CONTEXT_CHECK = 'echo "$(whoami):$(pwd):$VAR"'
  
  def test_su_switches_user_for_duration_of_a_block
    setup_recipe do
      target.puts "export VAR=a"
      target.puts CONTEXT_CHECK
      su 'root' do
        target.puts CONTEXT_CHECK
        target.puts "export VAR=b"
        target.puts CONTEXT_CHECK
      end
      target.puts CONTEXT_CHECK
    end
  
    assert_output_equal %{
      linecook:/home/linecook:a
      root:/home/linecook:a
      root:/home/linecook:b
      linecook:/home/linecook:a
    }, *run_package
  end
  
  def test_nested_su
    setup_recipe do
      target.puts "export VAR=a"
      target.puts CONTEXT_CHECK
      su 'root' do
        target.puts CONTEXT_CHECK
        target.puts "export VAR=b"
        target.puts CONTEXT_CHECK
        su 'linecook' do
          target.puts CONTEXT_CHECK
          target.puts "export VAR=c"
          target.puts CONTEXT_CHECK
        end
        target.puts CONTEXT_CHECK
      end
      target.puts CONTEXT_CHECK
    end
  
    assert_output_equal %{
      linecook:/home/linecook:a
      root:/home/linecook:a
      root:/home/linecook:b
      linecook:/home/linecook:b
      linecook:/home/linecook:c
      root:/home/linecook:b
      linecook:/home/linecook:a
    }, *run_package
  end
  
  #
  # useradd test
  #
  
  def test_useradd_adds_user
    clear_test_user
    
    setup_recipe do
      login do
        target.puts "if id #{TEST_USER}; then exit 1; fi"
        useradd TEST_USER
        target.puts "if ! id #{TEST_USER}; then exit 1; fi"
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
  
  #
  # userdel test
  #
  
  def test_userdel_removes_user
    clear_test_user
    
    setup_recipe do
      login do
        target.puts "useradd #{TEST_USER}"
        target.puts "if ! id #{TEST_USER}; then exit 1; fi"
        userdel TEST_USER
        target.puts "if id #{TEST_USER}; then exit 1; fi"
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
end