(name, options={})
--
  unless_ _group?(name) do
    groupadd name
  end
  