(name, options={})
--
  not_if _group?(name) do
    groupadd name
  end
  