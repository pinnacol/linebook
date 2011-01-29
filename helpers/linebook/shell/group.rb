(name, options={})
--
  not_if _group?(name) do
    addgroup name
  end