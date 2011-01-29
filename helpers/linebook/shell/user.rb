(name, options={})
--
  not_if _user?(name) do
    adduser name
  end