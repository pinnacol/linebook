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
        writeln %{userdel  #{TEST_USER}      > /dev/null 2>&1}
        writeln %{userdel  #{TEST_USER_TWO}  > /dev/null 2>&1}
        writeln %{groupdel #{TEST_GROUP}     > /dev/null 2>&1}
        writeln %{groupdel #{TEST_GROUP_TWO} > /dev/null 2>&1}
      end
      writeln "true"
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
        if_ _group?(TEST_GROUP) do
          writeln "exit 1"
        end
        
        groupadd TEST_GROUP
        
        unless_ _group?(TEST_GROUP) do
          writeln "exit 1"
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
        unless_ _group?("$(id -ng $(whoami))") do
          writeln "exit 1"
        end
        
        if_ _group?(TEST_GROUP) do
          writeln "exit 1"
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
        writeln "groupadd #{TEST_GROUP}"
        
        unless_ _group?(TEST_GROUP) do
          writeln "exit 1"
        end
        
        groupdel TEST_GROUP
        
        if_ _group?(TEST_GROUP) do
          writeln "exit 1"
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
        writeln "groupadd #{TEST_GROUP}"
        writeln "groupadd #{TEST_GROUP_TWO}"
        writeln "useradd -g #{TEST_GROUP_TWO} -G #{TEST_GROUP} #{TEST_USER}"
      end
      
      groups(TEST_USER)
    end
    
    assert_output_equal %{
      #{TEST_GROUP_TWO} #{TEST_GROUP}
    }, *run_package
  end
  
  #
  # install test
  #
  
  def test_install_copies_source_to_target
    setup_recipe 'recipe' do
      cd package_dir
      echo('content').to('source')
      
      install 'source', 'target'
      cat 'target'
    end
    
    assert_output_equal %{
      content
    }, *run_package
  end
  
  def test_install_backs_up_existing_target_if_specified
    setup_recipe 'recipe' do
      cd package_dir
      echo('new').to('source')
      echo('old').to('target')
      
      install 'source', 'target', :backup => true
      
      cat 'target~'
      cat 'target'
    end
    
    assert_output_equal %{
      old
      new
    }, *run_package
  end
  
  #
  # login test
  #
  
  def test_login_logs_in_as_user_for_duration_of_a_block
    setup_recipe do
      writeln "export VAR=a"
      writeln CONTEXT_CHECK
      login 'root' do
        writeln CONTEXT_CHECK
        writeln "export VAR=b"
        writeln CONTEXT_CHECK
      end
      writeln CONTEXT_CHECK
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
        writeln "say_hello $(whoami)"
      end
    end
  
    assert_match(/command not found/, *run_package)
  end
  
  def test_nested_login
    setup_recipe do
      writeln "export VAR=a"
      writeln CONTEXT_CHECK
      login 'root' do
        writeln CONTEXT_CHECK
        writeln "export VAR=b"
        writeln CONTEXT_CHECK
        login 'linecook' do
          writeln CONTEXT_CHECK
          writeln "export VAR=c"
          writeln CONTEXT_CHECK
        end
        writeln CONTEXT_CHECK
      end
      writeln CONTEXT_CHECK
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
      writeln "export VAR=a"
      writeln CONTEXT_CHECK
      su 'root' do
        writeln CONTEXT_CHECK
        writeln "export VAR=b"
        writeln CONTEXT_CHECK
      end
      writeln CONTEXT_CHECK
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
      writeln "say_hello $(whoami)"
      su do
        writeln "say_hello $(whoami)"
      end
      writeln "say_hello $(whoami)"
    end
  
    assert_output_equal %{
      hello linecook
      hello root
      hello linecook
    }, *run_package
  end
  
  def test_nested_su
    setup_recipe do
      writeln "export VAR=a"
      writeln CONTEXT_CHECK
      su 'root' do
        writeln CONTEXT_CHECK
        writeln "export VAR=b"
        writeln CONTEXT_CHECK
        su 'linecook' do
          writeln CONTEXT_CHECK
          writeln "export VAR=c"
          writeln CONTEXT_CHECK
        end
        writeln CONTEXT_CHECK
      end
      writeln CONTEXT_CHECK
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
        if_ _user?(TEST_USER) do
          writeln "exit 1"
        end
        
        useradd TEST_USER
        
        unless_ _user?(TEST_USER) do
          writeln "exit 1"
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
        unless_ _user?("$(whoami)") do
          writeln "exit 1"
        end
        
        if_ _user?(TEST_USER) do
          writeln "exit 1"
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
        writeln "useradd #{TEST_USER}"
        
        unless_ _user?(TEST_USER) do
          writeln "exit 1"
        end
        
        userdel TEST_USER
        
        if_ _user?(TEST_USER) do
          writeln "exit 1"
        end
      end
    end
    
    stdout, msg = run_package
    assert_equal 0, $?.exitstatus, msg
  end
end