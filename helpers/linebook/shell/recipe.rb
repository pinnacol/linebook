(recipe_name)
--
  target_name = File.join('recipes', recipe_name)
  runlist = target_path "runlist.log"
  recipe_path = _package_.registry.has_key?(target_name) ? 
    target_path(target_name) : 
    self.recipe_path(recipe_name, target_name)
  
  not_if %{grep -xqs "#{recipe_name}" "#{runlist}"} do
    target.puts %{echo "#{recipe_name}" >> "#{runlist}"}
    target.puts %{"#{shell_path}" "#{recipe_path}" $*}
    check_status
  end
