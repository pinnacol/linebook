(recipe_name)
--
  target_name = File.join('recipes', recipe_name)
  recipe_path = _package_.registry.has_key?(target_name) ? 
    target_path(target_name) : 
    self.recipe_path(recipe_name, target_name, 0777)

  dir = target_path File.join('tmp', recipe_name)
  unless_ _directory?(dir) do
    current = target_path('tmp')
    recipe_name.split('/').each do |segment|
      current = File.join(current, segment)
      directory current, :mode => 0770
    end
    writeln "#{quote(recipe_path)} $*"
    check_status
  end
