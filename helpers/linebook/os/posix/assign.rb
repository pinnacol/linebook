Assign a file descriptor.
(target, source)
--
  target = handles[target] || target
  target = nil if target == 0
  
  source = handles[source] || source
  source = source.kind_of?(Fixnum) ? "&#{source}" : " #{source}"
  
  match = chain? ? rewrite(CHECK_STATUS) : nil
  write " #{target}<#{source}"
  write match[1] if match
