Sets the options to on (true) or off (false) as specified. If a block is given
then options will only be reset when the block completes.

(options)
--
  if block_given?
    var = _package_.next_variable_name('set')
    patterns = options.keys.collect {|key| "-e #{key}" }.sort
    writeln %{#{var}=$(set +o | grep #{patterns.join(' ')})}
  end

  super

  if block_given?
    yield
    writeln %{eval "$#{var}"}
  end