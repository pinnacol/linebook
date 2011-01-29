require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/shell/posix'

class PosixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup_recipe(target_path='recipe')
    super.extend Linebook::Shell::Posix
  end
  
  #
  # check_status test
  #
  
  def test_check_status_only_prints_if_check_status_function_is_present
    assert_recipe('') { check_status } 
    
    assert_recipe %Q{
      check_status () { if [ $1 -ne $2 ]; then echo "[$2] $0:$3"; exit $2; else return $1; fi }
      check_status 0 $? $LINENO
      
    } do
      check_status_function
      check_status
    end
  end
  
  def test_check_status_silently_passes_if_error_status_is_as_expected
    build do
      check_status_function
      
      target.puts 'true'
      check_status
      
      target.puts 'false'
      check_status 1
    end
    
    assert_script %Q{
      % sh package/recipe # [1]
    }
  end
  
  def test_check_status_exits_with_error_status_if_status_is_not_as_expected
    build do
      check_status_function
      target.puts 'true'
      check_status 1
    end
    
    assert_script %{
      % sh package/recipe
      [0] package/recipe:3
    } 
    
    build do
      check_status_function
      target.puts 'false'
      check_status
    end
    
    assert_script %{
      % sh package/recipe # [1]
      [1] package/recipe:3
    } 
  end
  
  #
  # cmd test
  #
  
  def test_cmd_formats_a_generalized_command
    assert_recipe %q{
      command_name -a --bc "one" "two" "three"
    } do
      cmd 'command_name', '-a', '--bc', 'one', 'two', 'three'
    end
  end
  
  #
  # comment test
  #
  
  def test_comment_writes_a_comment_string
    assert_recipe %q{
      # string
    } do
      comment 'string'
    end
  end
  
  #
  # export test
  #
  
  def test_export_exports_variables
    assert_recipe %q{
      export ONE=A
      export TWO=B
      
    } do
      export [
        ['ONE', 'A'],
        ['TWO', 'B']
      ]
    end
  end
  
  def test_export_exports_variables_for_the_duration_of_a_block
    assert_recipe %q{
      export ONE=A
      export TWO=B
        # content
      unset ONE
      unset TWO
      
    } do
      export [
        ['ONE', 'A'],
        ['TWO', 'B']
      ] do
        target.puts "# content"
      end
    end
  end
  
  #
  # heredoc test
  #
  
  def test_heredoc_creates_a_heredoc_statement_using_the_block
    assert_recipe %q{
      << EOF
      line one  
        line two
      EOF
    } do
      heredoc :delimiter => 'EOF' do
        target.puts 'line one  '
        target.puts '  line two'
      end
    end
  end
  
  def test_heredoc_increments_default_delimiter
    assert_recipe %q{
      << HEREDOC_0
      HEREDOC_0
      << HEREDOC_1
      HEREDOC_1
    } do
      heredoc {}
      heredoc {}
    end
  end
  
  def test_heredoc_quotes_if_specified
    assert_recipe %q{
      << "HEREDOC_0"
      HEREDOC_0
    } do
      heredoc(:quote => true) {}
    end
  end
  
  def test_heredoc_flags_indent_if_specified
    assert_recipe %q{
      <<-HEREDOC_0
      HEREDOC_0
    } do
      heredoc(:indent => true) {}
    end
  end
  
  def test_heredoc_works_as_a_heredoc
    build do
      target << 'cat '
      heredoc {
        target.puts 'content'
      }
    end
    
    assert_script %Q{
      % sh package/recipe
      content
    }
  end
  
  #
  # not_if test
  #
  
  def test_not_if_reverses_condition
    assert_recipe %q{
      if ! condition
      then
      fi
      
    } do
      not_if('condition') {}
    end
  end
  
  #
  # only_if test
  #
  
  def test_only_if_encapsulates_block_in_if_statement
    assert_recipe %q{
      if condition
      then
        content
      fi
      
    } do
      only_if('condition') { target << 'content' }
    end
  end
  
  #
  # set_options test
  #
  
  def test_set_options_writes_set_operations_to_set_options
    assert_recipe %q{
      set -o verbose
      set +o xtrace
    } do
      set_options(:verbose => true, :xtrace => false)
    end
  end
  
  def test_set_options_functions_to_set_options
    build do
      target.puts 'echo a'
      set_options(:verbose => true)
      target.puts 'echo b'
      set_options(:verbose => false)
      target.puts 'echo c'
    end
    
    assert_script %Q{
      % sh package/recipe 2>&1
      a
      echo b
      b
      set +o verbose
      c
    } 
  end
  
  #
  # unset test
  #
  
  def test_unset_unsets_a_list_of_variables
    assert_recipe %q{
      unset ONE
      unset TWO
    } do
      unset 'ONE', 'TWO'
    end
  end
end