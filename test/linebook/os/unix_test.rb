require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/unix'

class UnixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Unix
  end
  
  #
  # chmod test
  #
  
  def test_chomd_chmods_a_file
    setup_recipe do
      target.puts 'touch file'
      target.puts 'chmod 644 file'
      target.puts 'ls -la file'
      chmod '600', 'file'
      target.puts 'ls -la file'
    end
    
    assert_alike %{
      -rw-r--r-- :...: file
      -rw------- :...: file
    }, *run_package
  end
  
  def test_chmod_does_nothing_for_no_mode
    assert_recipe %q{
    } do
      chmod nil, 'target'
    end
  end
  
  def test_chmod_may_prefix
    assert_recipe %q{
      sudo chmod "600" "target"
    } do
      with_execute_prefix 'sudo ' do
        chmod '600', 'target'
      end
    end
  end
  
  #
  # chown test
  #
  
  def test_chown_sets_up_file_chown
    assert_recipe_matches %q{
      chown "user:group" "target"
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
  
  def test_chown_may_prefix
    assert_recipe %q{
      sudo chown "user:group" "target"
    } do
      with_execute_prefix 'sudo ' do
        chown 'user', 'group', 'target'
      end
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
  
  def test_cp_f
    assert_recipe %q{
      cp -f "source" "target"
    } do
      cp_f 'source', 'target'
    end
  end
  
  def test_cp_r
    assert_recipe %q{
      cp -r "source" "target"
    } do
      cp_r 'source', 'target'
    end
  end
  
  def test_cp_rf
    assert_recipe %q{
      cp -rf "source" "target"
    } do
      cp_rf 'source', 'target'
    end
  end
  
  def test_cp_may_prefix
    assert_recipe %q{
      sudo cp "source" "target"
    } do
      with_execute_prefix 'sudo ' do
        cp 'source', 'target'
      end
    end
  end
  
  #
  # set_date test
  #
  
  def test_set_date_sets_the_system_date_to_the_specified_time
    time = Time.now
    
    setup_recipe do
      set_date time
      target.puts "date '+%Y-%m-%d %H:%M'"
    end
    
    assert_output_equal %{
      #{time.strftime("%Y-%m-%d %H:%M")}
    }, *run_package
  end
  
  def test_set_date_adjusts_to_utc
    time  = Time.now
    
    setup_recipe do
      set_date time.dup.utc
      target.puts "date '+%Y-%m-%d %H:%M'"
    end
    
    assert_output_equal %{
      #{time.strftime("%Y-%m-%d %H:%M")}
    }, *run_package
  end
  
  #
  # date test
  #
  
  def test_date_prints_date_in_specified_format
    setup_recipe do
      target.puts "sudo date 031008301979 > /dev/null"
      date "%Y-%m-%d %H:%M"
    end
    
    assert_output_equal %{
      1979-03-10 08:30
    }, *run_package
  end
  
  #
  # echo test
  #
  
  def test_echo
    assert_recipe(%{
      echo 'a b c'
    }){
      echo 'a', 'b c'
    }
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
  
  def test_ln_may_prefix
    assert_recipe %q{
      sudo ln "source" "target"
    } do
      with_execute_prefix 'sudo ' do
        ln 'source', 'target'
      end
    end
  end
  
  #
  # mkdir test
  #
  
  def test_mkdir
    assert_recipe %q{
      mkdir "target"
    } do
      mkdir 'target'
    end
  end
  
  def test_mkdir_p
    assert_recipe %q{
      mkdir -p "target"
    } do
      mkdir_p 'target'
    end
  end
  
  def test_mkdir_may_prefix
    assert_recipe %q{
      sudo mkdir "target"
    } do
      with_execute_prefix 'sudo ' do
        mkdir 'target'
      end
    end
  end
  
  #
  # mv test
  #
  
  def test_mv
    assert_recipe %q{
      mv "source" "target"
    } do
      mv 'source', 'target'
    end
  end
  
  def test_mv_f
    assert_recipe %q{
      mv -f "source" "target"
    } do
      mv_f 'source', 'target'
    end
  end
  
  def test_mv_may_prefix
    assert_recipe %q{
      sudo mv "source" "target"
    } do
      with_execute_prefix 'sudo ' do
        mv 'source', 'target'
      end
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
      set $LINECOOK_OPTS > /dev/null
      
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
      set $LINECOOK_OPTS > /dev/null
      
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
      set $LINECOOK_OPTS > /dev/null
      
    } do
      xtrace do
        target.puts 'echo a'
      end
    end
  end
  
  #
  # rm test
  #
  
  def test_rm_removes_a_file
    setup_recipe do
      target.puts 'touch file'
      rm 'file'
      
      target.puts 'if ! [ -e file ]; then echo success; fi'
    end
    
    assert_output_equal %{
      success
    }, *run_package
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
  
  def test_rm_may_prefix
    assert_recipe %q{
      sudo rm "source" "target"
    } do
      with_execute_prefix 'sudo ' do
        rm 'source', 'target'
      end
    end
  end
  
  #
  # shebang test
  #
  
  def test_shebang_uses_LINECOOK_DIR_if_set
    setup_recipe 'recipe' do
      target.puts "LINECOOK_DIR='current'"
      shebang
      target.puts 'echo "$LINECOOK_DIR"'
    end
    
    assert_output_equal %{
      current
    }, *run_package
  end
  
  def test_shebang_exports_LINECOOK_DIR
    setup_recipe 'outer' do
      target.puts "LINECOOK_DIR='current'"
      shebang
      target.puts 'echo outer'
      target.puts 'echo "$LINECOOK_DIR"'
      
      capture_path('inner') do
        target.puts 'echo inner'
        target.puts 'echo "$LINECOOK_DIR"'
      end
      
      target.puts %{sh "$(dirname $0)/inner"}
    end
    
    assert_output_equal %{
      outer
      current
      inner
      current
    }, *run_package
  end
  
  def test_shebang_sets_LINECOOK_DIR_to_recipe_dirname
    setup_recipe 'recipe' do
      shebang
      target.puts 'echo "$LINECOOK_DIR"'
    end
    
    assert_output_equal %{
      /tmp/package
    }, *run_package('remote_dir' => '/tmp/package')
  end
  
  def test_shebang_uses_LINECOOK_OPTS_if_set
    setup_recipe 'recipe' do
      target.puts "LINECOOK_OPTS='+v +x'"
      shebang
      target.puts 'echo "$LINECOOK_OPTS"'
    end
    
    assert_output_equal %{
      +v +x
    }, *run_package
  end
  
  def test_shebang_exports_LINECOOK_OPTS
    setup_recipe 'outer' do
      target.puts "LINECOOK_OPTS='+v +x'"
      shebang
      target.puts 'echo outer'
      target.puts 'echo "$LINECOOK_OPTS"'
      
      capture_path('inner') do
        target.puts 'echo inner'
        target.puts 'echo "$LINECOOK_OPTS"'
      end
      
      target.puts %{sh "$(dirname $0)/inner"}
    end
    
    assert_output_equal %{
      outer
      +v +x
      inner
      +v +x
    }, *run_package
  end
  
  def test_shebang_sets_LINECOOK_OPTS_to_verbose
    setup_recipe 'recipe' do
      shebang
      target.puts 'echo "$LINECOOK_OPTS"'
    end
    
    assert_output_equal %{
      -v
    }, *run_package
  end
end