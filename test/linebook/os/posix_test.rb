require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/posix'

class PosixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Posix
  end
  
  #
  # append test
  #
  
  def test_append_adds_stdout_append_to_file
    assert_recipe %q{
      cat source >> target
    } do
      writeln "cat source"
      chain :append, 'target'
    end
  end
  
  def test_append_redirects_to_dev_null_for_no_input
    assert_recipe %q{
      cat source >> /dev/null
    } do
      writeln "cat source"
      chain :append
    end
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
  # break test
  #
  
  def test_break__adds_a_break_statement
    assert_recipe %q{
      break
    } do
      break_
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
  # continue_ test
  #
  
  def test_continue__adds_a_continue_statement
    assert_recipe %q{
      continue
    } do
      continue_
    end
  end
  
  #
  # elif_ test
  #
  
  def test_elif__raises_error_if_not_used_with_if_
    err = assert_raises(RuntimeError) do
      setup_recipe do
        elif_('fail') {}
      end
    end
    
    assert_equal 'elif_ used outside of if_ statement', err.message
  end
  
  #
  # else_ test
  #
  
  def test_else__raises_error_if_not_used_with_if_
    err = assert_raises(RuntimeError) do
      setup_recipe do
        else_ {}
      end
    end
    
    assert_equal 'else_ used outside of if_ statement', err.message
  end
  
  #
  # exit_ test
  #
  
  def test_exit__adds_an_exit_0_statement
    assert_recipe %q{
      exit 0
      exit 8
    } do
      exit_
      exit_ 8
    end
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
  
  def test_format_cmd_skips_nil_args
    cmd = recipe.format_cmd 'which', nil, 'name'
    assert_equal 'which "name"', cmd
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
  
  def test_format_options_sorts_options_such_that_short_options_win
    assert_equal %w{
      --a-long --b-long --c-long -a -b -c
    }, recipe.format_options(
      'a' => true, 'b' => true, 'c' => true,
      'a-long' => true, 'b-long' => true, 'c-long' => true
    )
  end
  
  #
  # function test
  #
  
  def test_function_defines_a_function_from_the_block
    setup_recipe do
      function 'say_hello' do
        writeln 'echo "hello $1"'
      end
      writeln "say_hello world"
    end
    
    assert_output_equal %q{
      hello world
    }, *run_package
  end
  
  def test_function_substitutes_positional_params_for_variable_names
    setup_recipe do
      function 'get' do |a, b|
        writeln "echo \"got #{a}\""
        writeln "echo \"got #{b}\""
      end
      writeln "get one two"
    end
    
    assert_output_equal %q{
      got one
      got two
    }, *run_package
  end
  
  def test_function_supports_splat_signatures
    setup_recipe do
      function 'get' do |a, b, *c|
        writeln "echo \"got #{a}\""
        writeln "echo \"got #{b}\""
        writeln "echo \"got #{c}\""
      end
      writeln "get one two three four five"
    end
    
    assert_output_equal %q{
      got one
      got two
      got three four five
    }, *run_package
  end
  
  def test_function_allows_multiple_declarations_of_the_same_function
    setup_recipe do
      3.times do
        function 'say_hello' do
          writeln 'echo "hello $1"'
        end
      end
      writeln "say_hello world"
    end
    
    assert_output_equal %q{
      hello world
    }, *run_package
  end
  
  def test_function_raises_an_error_for_the_same_name_and_different_content
    err = assert_raises(RuntimeError) do
      setup_recipe do
        function 'say_hello' do
          writeln 'echo "hello $1"'
        end
        function 'say_hello' do
          writeln 'echo "goodbye $1"'
        end
      end
    end
    
    assert_equal 'function already defined: "say_hello"', err.message
  end
  
  #
  # export test
  #
  
  def test_export_exports_variables
    assert_recipe %q{
      export ONE="A"
      export TWO="B C"
    } do
      export 'ONE', 'A'
      export 'TWO', 'B C'
    end
  end
  
  #
  # from test
  #
  
  def test_from_chains_stdin_assignment_from_file
    assert_recipe %q{
      cat < source
    } do
      writeln "cat"
      chain :from, 'source'
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
        writeln 'line one  '
        writeln '  line two'
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
        writeln 'success'
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
      writeln "#"
      indent do
        target.print 'cat '; heredoc do
          writeln "a"
          writeln "\tb"
          writeln "\t\tc"
          writeln "    x"
          writeln "  y"
          writeln "z"
        end
      end
      writeln "#"
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
      writeln "#"
      indent do
        target.print 'cat '; heredoc :outdent => true do
          writeln "a"
          writeln "\tb"
          writeln "\t\tc"
          writeln "    x"
          writeln "  y"
          writeln "z"
        end
      end
      writeln "#"
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
  
  def test_heredoc_rstrips_on_chain
    assert_recipe %q{
      cat << HEREDOC_0
      success
      HEREDOC_0
    } do
      target.print "cat  \n   "
      chain :heredoc do
        writeln 'success'
      end
    end
  end
  
  #
  # unless_ test
  #
  
  def test_unless__reverses_condition
    assert_recipe %q{
      if ! condition
      then
      fi
      
    } do
      unless_('condition') {}
    end
  end
  
  def test_unless__with_else_
    assert_recipe %q{
      if ! A
      then
        a
      else
        b
      fi
      
    } do
      unless_('A') { write  'a' }
      else_ { write  'b' }
    end
  end
  
  #
  # if_ test
  #
  
  def test_if__encapsulates_block_in_if_statement
    assert_recipe %q{
      if condition
      then
        content
      fi
      
    } do
      if_('condition') { write  'content' }
    end
  end
  
  def test_if__with_elif___and_else_
    assert_recipe %q{
      if A
      then
        a
      elif B
      then
        b
      else
        c
      fi
      
    } do
      if_('A') { write  'a' }
      elif_('B') { write 'b' }
      else_ { write  'c' }
    end
  end
  
  def test_if__with_elif___and_else__using_chains
    assert_recipe %q{
      if A
      then
        a
      elif B
      then
        b
      else
        c
      fi
      
    } do
      if_('A') { 
        write  'a'
      }.elif_('B') {
        write 'b'
      }.else_ {
        write  'c'
      }
    end
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
  
  def test_quote_stringifies_args
    assert_equal %{"sym"}, recipe.quote(:sym)
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
    assert_equal false, recipe.quote?("+o")
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
  # redirect test
  #
  
  def test_redirect_chains_redirect_to_file
    assert_recipe %q{
      cat source 2> target
    } do
      writeln "cat source"
      chain :redirect, 2, 'target'
    end
  end
  
  def test_redirect_treats_numbers_as_file_handles
    assert_recipe %q{
      cat source 2>&1
    } do
      writeln "cat source"
      chain :redirect, 2, 1
    end
  end
  
  def test_redirect_allows_specification_of_redirection_type
    assert_recipe %q{
      cat a < source
      cat b >> target
    } do
      writeln "cat a"
      chain :redirect, nil, 'source', '<'
      writeln "cat b"
      chain :redirect, nil, 'target', '>>'
    end
  end
  
  #
  # return_ test
  #
  
  def test_return__adds_a_return_statement
    assert_recipe %q{
      return 0
      return 8
    } do
      return_
      return_ 8
    end
  end
  
  #
  # set test
  #
  
  def test_set_sets_options
    assert_recipe %q{
      set -o verbose
      set +o xtrace
    } do
      set(:verbose => true, :xtrace => false)
    end
  end
  
  #
  # to test
  #
  
  def test_to_chains_stdout_redirect_to_file
    assert_recipe %q{
      cat source > target
    } do
      writeln "cat source"
      chain :to, 'target'
    end
  end
  
  def test_to_redirects_to_dev_null_for_nil
    assert_recipe %q{
      cat source > /dev/null
    } do
      writeln "cat source"
      chain :to, nil
    end
  end
  
  def test_to_redirects_to_dev_null_for_no_file
    assert_recipe %q{
      cat source > /dev/null
    } do
      writeln "cat source"
      chain :to
    end
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
  
  #
  # until_ test
  #
  
  def test_until__makes_a_until_statement
    assert_recipe %q{
      until condition
      do
        content
      done
      
    } do
      until_('condition') { write  'content' }
    end
  end
  
  #
  # variable test
  #
  
  def test_variable_sets_a_variable
    assert_recipe %q{
      KEY="VALUE"
    } do
      variable 'KEY', 'VALUE'
    end
  end
  
  def test_variable_respects_quoted_values
    assert_recipe %q{
      KEY='VALUE'
    } do
      variable 'KEY', "'VALUE'"
    end
  end
  
  #
  # while_ test
  #
  
  def test_while__makes_a_while_statement
    assert_recipe %q{
      while condition
      do
        content
      done
      
    } do
      while_('condition') { write  'content' }
    end
  end
end