Switches to the specified user for the duration of a block.  The current ENV
and pwd are preserved.
(user='root', &block)
--
  target_name = guess_target_name(user)
  path = capture_path(target_name, 0700) do
    functions.each do |function|
      target.puts function
    end
    instance_eval(&block)
  end
  execute 'su', user, path, :m => true
  