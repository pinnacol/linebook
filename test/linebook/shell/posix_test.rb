require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/shell/posix'

class PosixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    setup_host 'abox'
    setup_helpers Linebook::Shell::Posix
  end
  
  #
  # blank test
  #
  
  def test_blank_check_returns_false_for_non_empty_or_whitespace_string
    assert_equal false, recipe.blank?('abc')
  end
  
  class ToEmptyStr
    def to_s; ''; end
  end
  
  def test_blank_check_returns_true_for_objects_that_to_s_to_a_whitespace_string
    assert_equal true, recipe.blank?(nil)
    assert_equal true, recipe.blank?('')
    assert_equal true, recipe.blank?('   ')
    assert_equal true, recipe.blank?(ToEmptyStr.new)
  end
  
  #
  # quote test
  #
  
  def test_quote_encloses_arg_in_quotation_marks
    assert_equal %{"abc"}, recipe.quote("abc")
  end
  
  def test_quote_does_not_quote_options
    assert_equal %{--option}, recipe.quote("--option")
    assert_equal %{-o}, recipe.quote("-o")
  end
  
  def test_quote_does_not_double_quote
    assert_equal %{"abc"}, recipe.quote('"abc"')
    assert_equal %{'abc'}, recipe.quote("'abc'")
  end
  
  #
  # quote? test
  #
  
  def test_quote_check_returns_true_if_arg_is_not_quoted
    assert_equal true,  recipe.quote?("abc")
    assert_equal false, recipe.quote?("'abc'")
    assert_equal false, recipe.quote?('"abc"')
  end
  
  def test_quote_check_returns_false_if_arg_is_an_option
    assert_equal false, recipe.quote?("--option")
    assert_equal false, recipe.quote?("-o")
  end
  
  #
  # quoted? test
  #
  
  def test_quoted_check_returns_true_if_arg_is_quoted_by_quotation_marks_or_apostrophes
    assert_equal false, recipe.quoted?("abc")
    assert_equal true,  recipe.quoted?("'abc'")
    assert_equal true,  recipe.quoted?('"abc"')
  end
  
  #
  # format_cmd test
  #
  
  def test_format_cmd_formats_a_command
    cmd  = recipe.format_cmd('command', 'one', 'two', 'three', 'a' => true, 'b' => true, 'c' => true)
    assert_equal 'command -a -b -c "one" "two" "three"', cmd
  end
  
  def test_format_cmd_does_not_quote_quoted_args
    assert_equal %{command_name "one" 'two'}, recipe.format_cmd('command_name', '"one"', "'two'")
  end
  
  def test_format_cmd_quotes_partially_quoted_args
    assert_equal %{command_name "'one" "two'" "th'ree"}, recipe.format_cmd('command_name', "'one", "two'", "th'ree")
  end
  
  #
  # format_options test
  #
  
  def test_format_options_formats_key_value_options_to_options_array
    assert_equal ['--key "value"'], recipe.format_options('--key' => '"value"')
  end
  
  def test_format_options_quotes_values
    assert_equal ['--key "value"'], recipe.format_options('--key' => 'value')
  end
  
  def test_format_options_stringifies_values
    assert_equal ['--key "value"'], recipe.format_options('--key' => :value)
  end
  
  def test_format_options_omits_value_for_true
    assert_equal ['--key'], recipe.format_options('--key' => true)
  end
  
  def test_format_options_omits_options_with_false_or_nil_values
    assert_equal [], recipe.format_options('--key' => false)
    assert_equal [], recipe.format_options('--key' => nil)
  end
  
  def test_format_options_guesses_option_prefix_for_keys_that_need_them
    assert_equal ['--long', '-s'], recipe.format_options('long' => true, 's' => true)
  end
  
  def test_format_options_reformats_symbol_keys_with_dashes
    assert_equal ['--long-opt'], recipe.format_options(:long_opt => true)
  end
  
  def test_format_options_sorts_options
    assert_equal %w{
      -a -b -c -x -y -z
    }, recipe.format_options(
      'a' => true, 'b' => true, 'c' => true,
      'x' => true, 'y' => true, 'z' => true
    )
  end
  
  #
  # with_execute_prefix test
  #
  
  def test_with_execute_prefix_sets_execute_prefix_for_the_duration_of_a_block
    assert_equal nil, recipe.execute_prefix
    recipe.with_execute_prefix('prefix') do
      assert_equal 'prefix', recipe.execute_prefix
    end
    assert_equal nil, recipe.execute_prefix
  end
  
  #
  # with_execute_suffix test
  #
  
  def test_with_execute_suffix_sets_execute_suffix_for_the_duration_of_a_block
    assert_equal nil, recipe.execute_suffix
    recipe.with_execute_suffix('suffix') do
      assert_equal 'suffix', recipe.execute_suffix
    end
    assert_equal nil, recipe.execute_suffix
  end
  
  #
  # check_status test
  #
  
  def test_check_status_only_prints_if_check_status_function_is_present
    assert_recipe %q{
    } do
      check_status
    end
    
    assert_recipe_matches %q{
      check_status 0 $? $? $LINENO
    } do
      check_status_function
      check_status
    end
  end
  
  def test_check_status_silently_passes_if_error_status_is_as_expected
    setup_recipe 'pass_true' do
      check_status_function
      
      target.puts 'true'
      check_status
      
      target.puts 'echo pass_true'
    end
    
    setup_recipe 'pass_false' do
      check_status_function
      
      target.puts 'false'
      check_status 1
      
      target.puts 'echo pass_false'
    end
    
    assert_output_equal %{
      pass_true
      pass_false
    }, *run_package
  end
  
  def test_check_status_exits_with_error_status_if_status_is_not_as_expected
    setup_recipe 'fail_true' do
      check_status_function
      
      target.puts 'true'
      check_status 1
      
      target.puts 'echo flunk'
    end
    
    setup_recipe 'fail_false' do
      check_status_function
      
      target.puts 'false'
      check_status 0
      
      target.puts 'echo flunk'
    end
    
    # note the LINENO output is not directly tested here because as of 10.10
    # sh on Ubuntu does not support LINENO
    assert_alike %{
      [0] ./fail_true:...:
      [1] ./fail_false:...:
    }, *run_package
  end
  
  #
  # cmd test
  #
  
  def test_cmd_executes_cmd_and_checks_pass_status
    setup_recipe do
      check_status_function
      
      cmd 'true'
      target.puts 'echo success'
      
      cmd 'fail'
      target.puts 'echo fail'
    end
    
    assert_alike %{
      success
      [127] ./recipe:...:
    }, *run_package
  end
  
  #
  # execute test
  #
  
  def test_execute_executes_cmd_and_checks_pass_status
    setup_recipe do
      check_status_function
      
      execute 'true'
      target.puts 'echo success'
      
      execute 'fail'
      target.puts 'echo fail'
    end
    
    assert_alike %{
      success
      [127] ./recipe:...:
    }, *run_package
  end
  
  def test_execute_uses_current_execute_prefix_and_suffix
    assert_recipe %q{
      prefix command_name "a" "b" "c" suffix
    } do
      self.execute_prefix = "prefix "
      self.execute_suffix = " suffix"
      execute 'command_name', "a", "b", "c"
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
  
  def test_heredoc_flags_outdent_if_specified
    assert_recipe %q{
      <<-HEREDOC_0
      HEREDOC_0
    } do
      heredoc(:outdent => true) {}
    end
  end
  
  def test_heredoc_works_as_a_heredoc
    setup_recipe do
      target.print 'cat '; heredoc do
        target.puts 'success'
      end
    end
    
    assert_output_equal %{
      success
    }, *run_package
  end
  
  def test_heredoc_outdents_heredoc_body
    assert_recipe %{
      #
        cat << HEREDOC_0
      a
      \tb
      \t\tc
          x
        y
      z
      HEREDOC_0
      #
    } do
      target.puts "#"
      indent do
        target.print 'cat '; heredoc do
          target.puts "a"
          target.puts "\tb"
          target.puts "\t\tc"
          target.puts "    x"
          target.puts "  y"
          target.puts "z"
        end
      end
      target.puts "#"
    end
    
    assert_output_equal %{
      a
      \tb
      \t\tc
          x
        y
      z
    }, *run_package
  end
  
  def test_heredoc_works_with_indent_when_outdent_is_true
    assert_recipe %{
      #
        cat <<-HEREDOC_0
      a
      \tb
      \t\tc
          x
        y
      z
      HEREDOC_0
      #
    } do
      target.puts "#"
      indent do
        target.print 'cat '; heredoc :outdent => true do
          target.puts "a"
          target.puts "\tb"
          target.puts "\t\tc"
          target.puts "    x"
          target.puts "  y"
          target.puts "z"
        end
      end
      target.puts "#"
    end
    
    assert_output_equal %{
      a
      b
      c
          x
        y
      z
    }, *run_package
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
  
  # def test_set_options_functions_to_set_options
  #   build_package do
  #     target.puts 'echo a'
  #     set_options(:verbose => true)
  #     target.puts 'echo b'
  #     set_options(:verbose => false)
  #     target.puts 'echo c'
  #   end
  #   
  #   check_package %Q{
  #     % sh package/recipe 2>&1
  #     a
  #     echo b
  #     b
  #     set +o verbose
  #     c
  #   } 
  # end
  
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