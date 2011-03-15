Makes a redirect statement.
(source, target, redirection='>')
--
  source = handles[source] || source
  source = source.nil? || source.kind_of?(Fixnum) ? source : "#{source} "
  
  target = handles[target] || target
  target = target.nil? || target.kind_of?(Fixnum) ? "&#{target}" : " #{target}"
  
  match = chain? ? rewrite(CHECK_STATUS) : nil
  write " #{source}#{redirection}#{target}"
  write match[1] if match
  