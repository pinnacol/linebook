Makes a redirect statement.
(source, target, redirection='>')
--
  source = source.nil? || source.kind_of?(Fixnum) ? source : "#{source} "
  target = target.nil? || target.kind_of?(Fixnum) ? "&#{target}" : " #{target}"
  
  match = chain? ? rewrite(trailer) : nil
  write " #{source}#{redirection}#{target}"
  write match[1] if match
  