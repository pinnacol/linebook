Perform a gsub using sed.  Intended for use in chains.

(pattern, replacement, *args)
--
  unless args.last.kind_of?(Hash)
    args << {}
  end
  args.last[:e] = "s/#{pattern}/#{replacement}/g"
  sed(*args)