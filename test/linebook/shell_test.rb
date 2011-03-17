require File.expand_path('../../test_helper', __FILE__)
require 'linebook/shell'
require 'linebook/shell/bash'
require 'linebook/os/ubuntu'

class ShellTest < Test::Unit::TestCase
  include Linecook::Test
  
  def setup
    super
    use_helpers Linebook::Shell
  end
  
  #
  # guess_target_name test
  #
  
  def test_guess_target_name_is_the_base_name_of_the_source_under_the_target_namespace
    recipe = setup_recipe 'name/space/recipe'
    assert_equal 'name/space/name.txt', recipe.guess_target_name('source/name.txt')
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
  
  #
  # directory test
  #
  
  def test_directory_makes_the_target_directory
    setup_recipe do
      rm_r 'target'
      directory 'target'
      writeln 'ls -la .'
    end
    
    assert_alike %{
      drwxr-xr-x :...: target
    }, *run_package
  end
  
  def test_directory_makes_parent_dirs_as_needed
    setup_recipe do
      rm_r 'target'
      directory 'target/dir'
      writeln 'ls -la target'
    end
    
    assert_alike %{
      drwxr-xr-x :...: dir
    }, *run_package
  end
  
  def test_directory_sets_mode
    setup_recipe do
      rm_r 'target'
      directory 'target', :mode => 700
      writeln 'ls -la .'
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
      rm_r('target').to(nil).redirect(2, 1)
      file 'source/file.txt', 'target/file.txt'
      cat 'target/file.txt'
    end
    
    assert_output_equal %{
      content
    }, package.content('file.txt')
    
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
      rm_r('target').to(nil).redirect(2, 1)
      template 'source/file.txt', 'target/file.txt', :locals => {:key => 'value'}
      cat 'target/file.txt'
    end
    
    assert_output_equal %{
      got value
    }, package.content('file.txt')
    
    assert_output_equal %{
      got value
    }, *run_package
  end
  
  #
  # recipe test
  #
  
  def test_recipe_builds_and_executes_recipe
    prepare('recipes/source/recipe.rb', "writeln 'echo success'")
    
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
    prepare('recipes/source/recipe.rb', "writeln 'echo success'")
    
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
    prepare('recipes/source/recipe.rb', "writeln 'echo success'")
    
    setup_recipe 'a' do
      writeln "echo a"
      recipe 'source/recipe'
    end
    
    setup_recipe 'b' do
      writeln "echo b"
      recipe 'source/recipe'
    end
    
    assert_output_equal %{
      a
      success
      b
    }, *run_package
  end
  
  def test_recipe_can_be_run_from_any_file_that_declares_it
    prepare('recipes/source/recipe.rb', "writeln 'echo success'")
    
    setup_recipe 'a' do
      writeln "echo a"
      recipe 'source/recipe'
    end
    
    setup_recipe 'b' do
      writeln "echo b"
      recipe 'source/recipe'
    end
    
    runlist = prepare('runlist') {|io| io.puts "b" }
    
    assert_output_equal %{
      b
      success
    }, *run_package('runlist' => runlist)
  end
  
  def remote_dir
    method_dir[(user_dir.length + 1)..-1]
  end
  
  def test_recipe_preserves_package_dir
    prepare('recipes/source/recipe.rb', 'writeln "echo #{package_dir}"')
    
    setup_recipe do
      echo package_dir
      recipe 'source/recipe'
    end
    
    assert_output_equal %{
      /home/linecook/#{remote_dir}
      /home/linecook/#{remote_dir}
    }, *run_package
  end
end