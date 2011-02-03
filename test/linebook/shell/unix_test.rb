require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/shell/unix'

class UnixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup_recipe(target_path='recipe')
    super.extend Linebook::Shell::Unix
  end
  
  #
  # chmod test
  #
  
  def test_chomd_chmods_a_file
    target = prepare('example')
    
    File.chmod(0644, target)
    assert_equal "100644", sprintf("%o", File.stat(target).mode)
    
    package = build_package { chmod 600, target }
    sh "sh #{package['recipe']}"
    
    assert_equal "100600", sprintf("%o", File.stat(target).mode)
  end
  
  def test_chmod_does_nothing_for_no_mode
    assert_recipe %q{
    } do
      chmod nil, 'target'
    end
  end
  
  #
  # chown test
  #
  
  def test_chown_sets_up_file_chown
    assert_recipe_match %q{
      chown user:group "target"
    } do
      chown 'user', 'group', 'target'
    end
  end
  
  def test_chown_does_nothing_for_no_user_or_group
    assert_recipe %q{
    } do
      chown nil, nil, 'target'
    end
  end
  
  #
  # cp test
  #
  
  def test_cp
    assert_recipe %q{
      cp "source" "target"
    } do
      cp 'source', 'target'
    end
  end
  
  def test_cp_r
    assert_recipe %q{
      cp -r "source" "target"
    } do
      cp_r 'source', 'target'
    end
  end
  
  #
  # ln test
  #
  
  def test_ln
    assert_recipe %q{
      ln "source" "target"
    } do
      ln 'source', 'target'
    end
  end
  
  def test_ln_s
    assert_recipe %q{
      ln -s "source" "target"
    } do
      ln_s 'source', 'target'
    end
  end
  
  #
  # quiet test
  #
  
  def test_quiet_turns_off_verbose_and_xtrace
    assert_recipe %q{
      set +x +v
      
    } do
      quiet
    end
  end
  
  def test_quiet_turns_off_verbose_and_xtrace_for_the_duration_of_a_block
    assert_recipe %q{
      set +x +v
        echo a
      set $LINECOOK_OPTIONS > /dev/null
      
    } do
      quiet do
        target.puts 'echo a'
      end
    end
  end
  
  #
  # verbose test
  #
  
  def test_verbose_turns_on_verbose
    assert_recipe %q{
      set -v
      
    } do
      verbose
    end
  end
  
  def test_verbose_turns_on_verbose_for_the_duration_of_a_block
    assert_recipe %q{
      set -v
        echo a
      set $LINECOOK_OPTIONS > /dev/null
      
    } do
      verbose do
        target.puts 'echo a'
      end
    end
  end
  
  #
  # xtrace test
  #
  
  def test_xtrace_turns_on_xtrace
    assert_recipe %q{
      set -x
      
    } do
      xtrace
    end
  end
  
  def test_xtrace_turns_on_xtrace_for_the_duration_of_a_block
    assert_recipe %q{
      set -x
        echo a
      set $LINECOOK_OPTIONS > /dev/null
      
    } do
      xtrace do
        target.puts 'echo a'
      end
    end
  end
  
  #
  # rm test
  #
  
  def test_rm_removes_a_file_if_present
    target = prepare('target')
    assert_equal true, File.exists?(target)
    
    package = build_package { rm target }
    sh "sh #{package['recipe']}"
    
    assert_equal false, File.exists?(target)
  end
  
  def test_rm
    assert_recipe %q{
      rm "target"
    } do
      rm 'target'
    end
  end
  
  def test_rm_r
    assert_recipe %q{
      rm -r "target"
    } do
      rm_r 'target'
    end
  end
  
  def test_rm_rf
    assert_recipe %q{
      rm -rf "target"
    } do
      rm_rf 'target'
    end
  end
end