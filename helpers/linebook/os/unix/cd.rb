(dir=nil)
--
  if block_given?
    var = _package_.next_variable_name('cd')
    target.puts %{#{var}=$(pwd)}
  end

  execute "cd", dir

  if block_given?
    yield
    execute "cd", "$#{var}"
  end