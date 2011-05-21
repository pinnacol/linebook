require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/linux'

class LinuxTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Linux
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
  # login test
  #

  CONTEXT_CHECK = 'echo "$(whoami):$(pwd):$VAR"'

  def test_login_makes_script_with_name_and_mode_as_specified
    setup_recipe 'name/space/recipe' do
      login 'root', :target_name => 'check_name', :mode => 0600 do
        write 'content'
      end
    end

    assert_equal 'content', package.content('check_name')
    assert_equal 0600, package.mode('check_name')
  end

  def test_login_guesses_target_name_from_non_hash_options
    setup_recipe 'name/space/recipe' do
      login 'root', 'desc' do
        write 'content'
      end
    end

    assert_equal 'content', package.content('name/space/desc')
  end

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
        writeln "echo 'is defined: #{function?('say_hello').inspect}'"
        writeln "say_hello $(whoami)"
      end
    end

    assert_alike %{
      is defined: false
      :...: say_hello: command not found
    }, *run_package
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
end