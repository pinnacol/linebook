require File.expand_path('../../test_helper', __FILE__)
require 'linebook/shell'
require 'linebook/shell/bash'
require 'linebook/os/ubuntu'

class ShellTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_host 'abox'
    use_helpers Linebook::Shell
  end
  
  #
  # guess_target_name test
  #
  
  def test_guess_target_name_is_the_base_name_of_the_source_under_the_target_name_directory
    recipe = setup_recipe 'recipe'
    assert_equal 'recipe.d/name.txt', recipe.guess_target_name('source/name.txt')
  end
  
  def test_guess_target_name_preserves_nested_recipe_names
    recipe = setup_recipe 'nest/recipe'
    assert_equal 'nest/recipe.d/name.txt', recipe.guess_target_name('source/name.txt')
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
  # directory test
  #
  
  def test_directory_makes_the_target_directory
    setup_recipe do
      target.puts 'rm -r target'
      directory 'target'
      target.puts 'ls -la .'
    end
    
    assert_alike %{
      drwxr-xr-x :...: target
    }, *run_package
  end
  
  def test_directory_makes_parent_dirs_as_needed
    setup_recipe do
      target.puts 'rm -r target'
      directory 'target/dir'
      target.puts 'ls -la target'
    end
    
    assert_alike %{
      drwxr-xr-x :...: dir
    }, *run_package
  end
  
  def test_directory_sets_mod
    setup_recipe do
      target.puts 'rm -r target'
      directory 'target', :mode => 700
      target.puts 'ls -la .'
    end
    
    assert_alike %{
      drwx------ :...: target
    }, *run_package
  end
  
  #
  # file test
  #
  
  def test_file_installs_the_source_file_in_package_to_target
    prepare('files/source/file.txt', "content\n")
    
    setup_recipe 'recipe' do
      target.puts 'rm -r target > /dev/null 2>&1'
      file 'source/file.txt', 'target/file.txt'
      target.puts 'cat target/file.txt'
    end
    
    assert_output_equal %{
      content
    }, package.content('recipe.d/file.txt')
    
    assert_output_equal %{
      content
    }, *run_package
  end
  
  #
  # template test
  #
  
  def test_template_builds_and_installs_the_corresponding_template_to_target
    prepare('templates/source/file.txt.erb', "got <%= key %>\n")
    
    setup_recipe 'recipe' do
      target.puts 'rm -r target > /dev/null 2>&1'
      template 'source/file.txt', 'target/file.txt', :locals => {:key => 'value'}
      target.puts 'cat target/file.txt'
    end
    
    assert_output_equal %{
      got value
    }, package.content('recipe.d/file.txt')
    
    assert_output_equal %{
      got value
    }, *run_package
  end
  
  #
  # recipe test
  #
  
  def test_recipe_builds_and_executes_recipe
    prepare('recipes/source/recipe.rb', "target.puts 'echo success'")
    
    setup_recipe do
      recipe 'source/recipe'
    end
    
    assert_output_equal %{
      echo success
    }, package.content('recipes/source/recipe')
    
    assert_output_equal %{
      success
    }, *run_package
  end
  
  def test_recipe_only_builds_once
    prepare('recipes/source/recipe.rb', "target.puts 'echo success'")
    
    setup_recipe 'a' do
      recipe 'source/recipe'
      recipe 'source/recipe'
    end
    
    setup_recipe 'b' do
      recipe 'source/recipe'
    end
    
    assert_equal %w{
      a
      b
      recipes/source/recipe
    }, package.registry.keys.sort
  end
  
  def test_recipe_only_runs_once
    prepare('recipes/source/recipe.rb', "target.puts 'echo success'")
    
    setup_recipe 'a' do
      target.puts "echo a"
      recipe 'source/recipe'
    end
    
    setup_recipe 'b' do
      target.puts "echo b"
      recipe 'source/recipe'
    end
    
    assert_output_equal %{
      a
      success
      b
    }, *run_package
  end
  
  def test_recipe_can_be_run_from_any_file_that_declares_it
    prepare('recipes/source/recipe.rb', "target.puts 'echo success'")
    
    setup_recipe 'a' do
      target.puts "echo a"
      recipe 'source/recipe'
    end
    
    setup_recipe 'b' do
      target.puts "echo b"
      recipe 'source/recipe'
    end
    
    runlist = prepare('runlist') {|io| io.puts "b" }
    
    assert_output_equal %{
      b
      success
    }, *run_package('runlist' => runlist)
  end
  
  #
  # install test
  #
  
  def test_install_copies_source_to_target
    setup_recipe 'recipe' do
      target.puts 'echo content > source'
      
      install 'source', 'target'
      
      target.puts 'cat target'
    end
    
    assert_output_equal %{
      content
    }, *run_package
  end
  
  def test_install_backs_up_existing_target
    setup_recipe 'recipe' do
      target.puts 'echo new > source'
      target.puts 'echo old > target'
      
      install 'source', 'target'
      
      target.puts 'cat target.bak'
      target.puts 'cat target'
    end
    
    assert_output_equal %{
      old
      new
    }, *run_package
  end
  
  def test_install_can_turn_off_backup
    setup_recipe 'recipe' do
      target.puts 'echo new > source'
      target.puts 'echo old > target'
      
      install 'source', 'target', :backup => false
      
      target.puts 'if ! [ -e target.bak ]; then echo pass; fi'
    end
    
    assert_output_equal %{
      pass
    }, *run_package
  end
  
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
  
  #
  # groupadd test
  #
  
  def test_groupadd_creates_commands_to_add_group
    assert_recipe %q{
      groupadd "name"
    } do
      groupadd 'name'
    end
  end
  
  #
  # useradd test
  #
  
  def test_useradd_creates_commands_to_add_user
    assert_recipe %q{
      useradd "name"
    } do
      useradd 'name'
    end
  end
end