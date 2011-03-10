require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/linux'

class LinuxTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Linux
  end
  
  TEST_USER      = 'test_user'
  TEST_GROUP     = 'test_group'
  TEST_USER_TWO  = 'test_user_two'
  TEST_GROUP_TWO = 'test_group_two'
  
  def clear_test_users
    setup_recipe do
      login do
        target.puts %{userdel  #{TEST_USER}      > /dev/null 2>&1}
        target.puts %{userdel  #{TEST_USER_TWO}  > /dev/null 2>&1}
        target.puts %{groupdel #{TEST_GROUP}     > /dev/null 2>&1}
        target.puts %{groupdel #{TEST_GROUP_TWO} > /dev/null 2>&1}
      end
      target.puts "true"
    end
  end
  
  #
  # doc test
  #
  
  def test_doc
    setup_recipe do
      cd
      export 'A', 'a'
      variable 'B', 'b'
      echo "$(whoami):$(pwd):$A:$B"             # => linecook:/home/linecook:a:b
      login { echo "$(whoami):$(pwd):$A:$B" }   # => root:/root::
      su { echo "$(whoami):$(pwd):$A:$B" }      # => root:/home/linecook:a:
    end
    
    assert_output_equal %{
      linecook:/home/linecook:a:b
      root:/root::
      root:/home/linecook:a:
    }, *run_package
  end
  
  #
  # groupadd test
  #
  
  def test_groupadd_adds_group
    clear_test_users
    
    setup_recipe do
      login do
        only_if _group?(TEST_GROUP) do
          target.puts "exit 1"
        end
        
        groupadd TEST_GROUP
        
        not_if _group?(TEST_GROUP) do
          target.puts "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
  
  #
  # group? test
  #
  
  def test_group_check_passes_if_the_group_exists
    clear_test_users
    
    setup_recipe do
      login do
        not_if _group?("$(id -ng $(whoami))") do
          target.puts "exit 1"
        end
        
        only_if _group?(TEST_GROUP) do
          target.puts "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
  
  #
  # groupdel test
  #
  
  def test_groupdel_removes_group
    clear_test_users
    
    setup_recipe do
      login do
        target.puts "groupadd #{TEST_GROUP}"
        
        not_if _group?(TEST_GROUP) do
          target.puts "exit 1"
        end
        
        groupdel TEST_GROUP
        
        only_if _group?(TEST_GROUP) do
          target.puts "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
  
  #
  # groups test
  #
  
  def test_groups_returns_groups_a_user_belongs_to
    clear_test_users
    
    setup_recipe do
      login do
        target.puts "groupadd #{TEST_GROUP}"
        target.puts "groupadd #{TEST_GROUP_TWO}"
        target.puts "useradd -g #{TEST_GROUP_TWO} -G #{TEST_GROUP} #{TEST_USER}"
      end
      
      groups(TEST_USER)
    end
    
    assert_output_equal %{
      #{TEST_GROUP_TWO} #{TEST_GROUP}
    }, *run_package
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
  
  def test_login_does_not_preserve_functions
    setup_recipe do
      function "say_hello" do
        echo 'hello $1'
      end
      login do
        target.puts "say_hello $(whoami)"
      end
    end
  
    assert_match(/command not found/, *run_package)
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
  
  def test_su_preserves_functions
    setup_recipe do
      function "say_hello" do
        echo 'hello $1'
      end
      target.puts "say_hello $(whoami)"
      su do
        target.puts "say_hello $(whoami)"
      end
      target.puts "say_hello $(whoami)"
    end
  
    assert_output_equal %{
      hello linecook
      hello root
      hello linecook
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
    clear_test_users
    
    setup_recipe do
      login do
        only_if _user?(TEST_USER) do
          target.puts "exit 1"
        end
        
        useradd TEST_USER
        
        not_if _user?(TEST_USER) do
          target.puts "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
  
  #
  # user? test
  #
  
  def test_user_check_passes_if_the_user_exists
    clear_test_users
    
    setup_recipe do
      login do
        not_if _user?("$(whoami)") do
          target.puts "exit 1"
        end
        
        only_if _user?(TEST_USER) do
          target.puts "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
  
  #
  # userdel test
  #
  
  def test_userdel_removes_user
    clear_test_users
    
    setup_recipe do
      login do
        target.puts "useradd #{TEST_USER}"
        
        not_if _user?(TEST_USER) do
          target.puts "exit 1"
        end
        
        userdel TEST_USER
        
        only_if _user?(TEST_USER) do
          target.puts "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
end