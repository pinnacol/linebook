require File.expand_path('../../test_helper', __FILE__)
require 'linebook/shell'
require 'linebook/shell/bash'
require 'linebook/os/ubuntu'

class ShellTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    setup_host 'abox'
    setup_helpers Linebook::Shell
  end
  
  #
  # extended test
  #
  
  def test_extending_with_shell_add_os_helper_if_specifed_in_attrs
    setup_package('linebook' => {'os' => nil})
    
    recipe = package.setup_recipe
    recipe.extend Linebook::Shell
    assert_equal false, setup_recipe.kind_of?(Linebook::Os::Ubuntu)
    
    setup_package('linebook' => {'os' => 'linebook/os/ubuntu'})
    
    recipe = package.setup_recipe
    recipe.extend Linebook::Shell
    assert_equal true, setup_recipe.kind_of?(Linebook::Os::Ubuntu)
  end
  
  def test_extending_with_shell_add_shell_helper_if_specifed_in_attrs
    setup_package('linebook' => {'shell' => nil})
    
    recipe = package.setup_recipe
    recipe.extend Linebook::Shell
    assert_equal false, setup_recipe.kind_of?(Linebook::Shell::Bash)
    
    setup_package('linebook' => {'shell' => 'linebook/shell/bash'})
    
    recipe = package.setup_recipe
    recipe.extend Linebook::Shell
    assert_equal true, setup_recipe.kind_of?(Linebook::Shell::Bash)
  end
  
  # #
  # # backup test
  # #
  # 
  # def test_backup_set_backup_permissions_to_644
  #   target = prepare('target', 'content')
  #   File.chmod(0754, target)
  #   
  #   build_package { backup target }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal '100644', sprintf("%o", File.stat("#{target}.bak").mode)
  # end
  # 
  # def test_backup_will_copy_if_specified
  #   target = prepare('target', 'content')
  #   
  #   build_package { backup target, :mv => false }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal 'content', File.read(target)
  #   assert_equal 'content', File.read("#{target}.bak")
  # end
  # 
  # #
  # # directory test
  # #
  # 
  # def test_directory_makes_the_target_directory
  #   target = path('target')
  #   assert_equal false, File.exists?(target)
  #   
  #   build_package { directory target }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal true, File.directory?(target)
  # end
  # 
  # def test_directory_makes_parent_dirs_as_needed
  #   target = path('target/dir')
  #   
  #   build_package { directory target }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal true, File.directory?(target)
  # end
  # 
  # def test_directory_sets_mode
  #   target = path('target')
  #   
  #   build_package { directory target, :mode => 700 }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal '40700', sprintf("%o", File.stat(target).mode)
  # end
  # 
  # #
  # # file test
  # #
  # 
  # def test_file_installs_the_corresponding_package_file_to_target
  #   prepare('files/file.txt', 'content')
  #   target = path('target/file.txt')
  #   
  #   build_package { file target }
  #   
  #   Dir.chdir(path('package'))
  #   assert_script "sh recipe"
  #   
  #   assert_equal 'content', File.read(target)
  # end
  # 
  # def test_file_can_specify_an_alternate_source
  #   prepare('files/source.txt', 'content')
  #   target = path('target.txt')
  #   
  #   build_package { file target, :source => 'source.txt' }
  #   
  #   Dir.chdir(path('package'))
  #   assert_script "sh recipe"
  #   
  #   assert_equal 'content', File.read(target)
  # end
  # 
  # #
  # # template test
  # #
  # 
  # def test_template_builds_and_installs_the_corresponding_template_to_target
  #   prepare('templates/file.txt.erb', 'got <%= key %>')
  #   target = path('target/file.txt')
  #   
  #   build_package { template target, :locals => {:key => 'value'} }
  #   
  #   Dir.chdir(path('package'))
  #   assert_script "sh recipe"
  #   
  #   assert_equal 'got value', File.read(target)
  # end
  # 
  # def test_template_can_specify_an_alternate_source
  #   prepare('templates/source.txt.erb', 'got <%= key %>')
  #   target = path('target.txt')
  #   
  #   build_package { template target, :source => 'source.txt', :locals => {:key => 'value'} }
  #   
  #   Dir.chdir(path('package'))
  #   assert_script "sh recipe"
  #   
  #   assert_equal 'got value', File.read(target)
  # end
  # 
  # #
  # # install test
  # #
  # 
  # def test_install_copies_source_to_target
  #   source = prepare('source', 'content')
  #   target = path('target')
  #   
  #   build_package { install source, target }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal 'content', File.read(source)
  #   assert_equal 'content', File.read(target)
  # end
  # 
  # def test_install_backs_up_existing_target
  #   source = prepare('source', 'new')
  #   target = prepare('target', 'old')
  #   
  #   build_package { install source, target }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal 'new', File.read(target)
  #   assert_equal 'old', File.read("#{target}.bak")
  # end
  # 
  # def test_install_can_turn_off_backup
  #   source = prepare('source', 'new')
  #   target = prepare('target', 'old')
  #   
  #   build_package { install source, target, :backup => false }
  #   assert_script "sh #{package['recipe']}"
  #   
  #   assert_equal false, File.exists?("#{target}.bak")
  # end
  # 
  def test_install_makes_parent_dirs_as_needed
    setup_recipe do
      target.puts 'echo content > source'
      install 'source', 'target/file'
      
      target.puts 'ls -la .'
    end
    
    assert_alike %{
      drwxr-xr-x :...: target
    }, *run_package
  end
  
  def test_install_allows_passing_options_to_directory
    setup_recipe do
      target.puts 'echo content > source'
      install 'source', 'target/file', :directory => {:mode => 700}
      
      target.puts 'ls -la .'
    end
    
    assert_alike %{
      drwx------ :...: target
    }, *run_package
  end
  
  def test_install_sets_mode
    setup_recipe do
      target.puts 'echo content > source'
      install 'source', 'target', :mode => 600
      target.puts 'ls -la .'
    end
    
    assert_alike %{
      -rw------- :...: target
    }, *run_package
  end
  
  #
  # shebang test
  #
  
  def test_shebang_adds_shebang_line_for_sh
    assert_recipe_matches %q{
      #! /bin/bash
      :...:
    } do
      shebang
    end
  end
  
  #
  # recipe test
  #
  
  def test_recipe_evals_recipe_into_recipe_file
    prepare('recipes/child.rb') {|io| io << "target << 'content'" }
    
    package.build_recipe('child')
    assert_equal 'content', package.content('child')
  end
end