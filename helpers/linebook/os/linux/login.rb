Logs in as the specified user for the duration of a block (the current ENV
and pwd are reset as during a normal login).
(user='root', options={}, &block)
--
  current = functions
  begin
    @functions = []
    
    unless options.kind_of?(Hash)
      options = {:target_name => guess_target_name(options)}
    end
    
    target_name = options[:target_name] || guess_target_name(user)
    path = capture_path(target_name, options[:mode] || 0700, &block)
    
    execute 'su', user, path, :l => true
  ensure
    @functions = current
  end
  