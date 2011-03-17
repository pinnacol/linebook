Switches to the specified user for the duration of a block.  The current ENV
and pwd are preserved.
(user='root', options={}, &block)
--
  unless options.kind_of?(Hash)
    options = {:target_name => guess_target_name(options)}
  end
  
  target_name = options[:target_name] || guess_target_name(user)
  path = capture_path(target_name, options[:mode] || 0700) do
    functions.each do |function|
      writeln function
    end
    instance_eval(&block)
  end
  execute 'su', user, path, :m => true
  