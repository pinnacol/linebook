Change the working directory, for the duration of a block if given.

(directory=nil, options={})
--
  if block_given?
    var = _package_.next_variable_name('cd')
    writeln %{#{var}=$(pwd)}
  end

  execute 'cd', directory, options

  if block_given?
    yield
    execute 'cd', "$#{var}"
  end