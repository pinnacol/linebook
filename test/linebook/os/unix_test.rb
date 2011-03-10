require File.expand_path('../../../test_helper', __FILE__)
require 'linebook/os/unix'

class UnixTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Os::Unix
  end
  
  #
  # cd test
  #
  
  def test_cd_changes_dir
    setup_recipe do
      target.puts 'pwd'
      cd '/tmp'
      target.puts 'pwd'
    end
    
    assert_output_equal %{
      /home/linecook
      /tmp
    }, *run_package
  end
  
  def test_cd_changes_dir_for_duration_of_a_block_if_given
    setup_recipe do
      target.puts 'pwd'
      cd '/tmp' do
        target.puts 'pwd'
        cd '/var'
        target.puts 'pwd'
      end
      target.puts 'pwd'
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
  # set_date test
  #
  
  def test_set_date_sets_the_system_date_to_the_specified_time
    time = Time.now
    
    setup_recipe do
      path = capture_path('set_date.sh') do
        set_date time
      end
      
      target.puts %{chmod +x "#{path}"}
      target.puts %{su root "#{path}" > /dev/null}
      target.puts "date '+%Y-%m-%d %H:%M'"
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
      
      target.puts %{chmod +x "#{path}"}
      target.puts %{su root "#{path}" > /dev/null}
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
      path = capture_path('set_date.sh') do
        target.puts "date 031008301979"
      end
      
      target.puts %{chmod +x "#{path}"}
      target.puts %{su root "#{path}" > /dev/null}
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
  
  #
  # set test
  #
  
  def test_set_sets_options_for_the_duration_of_a_block
    setup_recipe do
      target.puts 'set -v'
      target.puts 'echo a'
      set(:verbose => false, :xtrace => false) do
        target.puts 'echo b'
      end
      target.puts 'echo c'
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
end