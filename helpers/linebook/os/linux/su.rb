Switches to the specified user for the duration of a block.  The current ENV
and pwd are preserved.
(user='root', options={})
--
  path = capture_script(options) do
    functions.each do |function|
      writeln function
    end
    yield
  end
  execute 'su', user, path, :m => true
  