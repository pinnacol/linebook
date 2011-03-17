Switches to the specified user for the duration of a block.  The current ENV
and pwd are preserved.
(user='root', options={})
--
  unless options.kind_of?(Hash)
    options = {:target_name => guess_target_name(options)}
  end
  
  target_name = options[:target_name] || guess_target_name(user)
  path = capture_path(target_name, options[:mode] || 0700) do
    functions.each do |function|
      writeln function
    end
    yield
  end
  execute 'su', user, path, :m => true
  