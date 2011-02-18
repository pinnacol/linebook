require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/shell'
require 'linebook/shell/bash'

class BashTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    setup_host 'abox'
    setup_helpers Linebook::Shell, Linebook::Shell::Bash
  end
  
  #
  # cmd test
  #
  
  def test_cmd_quotes_non_option_args
    assert_recipe(%{
      ls -la "name"
    }){ 
      cmd 'ls', '-la', 'name'
    }
  end
  
  def test_cmd_skips_nil_args
    assert_recipe(%{
      which "name"
    }){ 
      cmd 'which', nil, 'name'
    }
  end
  
  #
  # su test
  #
  
  def test_su_wraps_block_content_in_a_recipe
    assert_recipe(%{
      su user "target"
    }){ 
      su('user', 'target') do 
        comment('content')
      end
    }
    
    assert_equal "# content\n", package.content('target')
  end
  
  def test_su_uses_user_name_as_default_target_name
    assert_recipe(%{
      su user "user"
    }){ 
      su('user') {}
    }
  end
  
  def test_nested_su
    assert_recipe %q{
      # +A
      su a "a"
      # -A
    } do
      comment('+A')
      su('a') do 
        comment('+B')
        su('b') do
          comment('+C')
          su('c') do
            comment('+D')
            comment('-D')
          end
          comment('-C')
        end
        comment('-B')
      end
      comment('-A')
    end
    
    assert_output_equal %q{
      # +B
      su b "b"
      # -B
    }, package.content('a')
    
    assert_output_equal %q{
      # +C
      su c "c"
      # -C
    }, package.content('b')
    
    assert_output_equal %q{
      # +D
      # -D
    }, package.content('c')
  end
end
