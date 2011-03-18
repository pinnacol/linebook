(name, options={})
--
  unless_ _user?(name) do
    useradd name, options
  end