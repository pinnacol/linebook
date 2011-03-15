require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/unix'

class UnixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Unix
  end
  
  #
  # cat test
  #
  
  def test_cat_allows_chaining
    setup_recipe do
      cat.heredoc do
        writeln "a"
        writeln "b"
        writeln "c"
      end
    end
    
    assert_output_equal %{
      a
      b
      c
    }, *run_package
  end
  
  #
  # cd test
  #
  
  def test_cd_changes_dir
    setup_recipe do
      writeln 'pwd'
      cd '/tmp'
      writeln 'pwd'
    end
    
    assert_output_equal %{
      /home/linecook
      /tmp
    }, *run_package
  end
  
  def test_cd_changes_dir_for_duration_of_a_block_if_given
    setup_recipe do
      writeln 'pwd'
      cd '/tmp' do
        writeln 'pwd'
        cd '/var'
        writeln 'pwd'
      end
      writeln 'pwd'
    end
    
    assert_output_equal %{
      /home/linecook
      /tmp
      /var
      /home/linecook
    }, *run_package
  end
  
  #
  # chmod test
  #
  
  def test_chomd_chmods_a_file
    setup_recipe do
      writeln 'touch file'
      writeln 'chmod 644 file'
      writeln 'ls -la file'
      chmod '600', 'file'
      writeln 'ls -la file'
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
  
  #
  # date test
  #
  
  def test_date_prints_date_in_specified_format
    setup_recipe do
      path = capture_path('set_date.sh') do
        writeln "date 031008301979"
      end
      
      writeln %{chmod +x "#{path}"}
      writeln %{su root "#{path}" > /dev/null}
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
      echo "a b c"
    }){
      echo 'a b c'
    }
  end
  
  #
  # gsub test
  #
  
  def test_gsub_makes_the_substitution_on_all_lines_of_the_input
    setup_recipe do
      gsub('a', 'A').heredoc do
        writeln 'a b a b'
        writeln 'b a b a'
      end
    end
    
    assert_output_equal %{
      A b A b
      b A b A
    }, *run_package
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
  
  #
  # rm test
  #
  
  def test_rm_removes_a_file
    setup_recipe do
      writeln 'touch file'
      rm 'file'
      
      writeln 'if ! [ -e file ]; then echo success; fi'
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
  
  #
  # set test
  #
  
  def test_set_sets_options_for_the_duration_of_a_block
    setup_recipe do
      writeln 'set -v'
      writeln 'echo a'
      set(:verbose => false, :xtrace => false) do
        writeln 'echo b'
      end
      writeln 'echo c'
    end
    
    # the number of set operations echoed is a little unpredicatable
    stdout, msg = run_package
    stdout.gsub!(/^set.*\n/, '')
    
    assert_output_equal %{
      echo a
      a
      b
      echo c
      c
    }, stdout, msg
  end
  
  #
  # set_date test
  #
  
  def test_set_date_sets_the_system_date_to_the_specified_time
    time = Time.now
    
    setup_recipe do
      path = capture_path('set_date.sh') do
        set_date time
      end
      
      writeln %{chmod +x "#{path}"}
      writeln %{su root "#{path}" > /dev/null}
      writeln "date '+%Y-%m-%d %H:%M'"
    end
    
    assert_output_equal %{
      #{time.strftime("%Y-%m-%d %H:%M")}
    }, *run_package
  end
  
  def test_set_date_adjusts_to_utc
    time  = Time.now
    
    setup_recipe do
      path = capture_path('set_date.sh') do
        set_date time.dup.utc
      end
      
      writeln %{chmod +x "#{path}"}
      writeln %{su root "#{path}" > /dev/null}
      writeln "date '+%Y-%m-%d %H:%M'"
    end
    
    assert_output_equal %{
      #{time.strftime("%Y-%m-%d %H:%M")}
    }, *run_package
  end
end