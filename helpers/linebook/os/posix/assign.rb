Assign a file descriptor.
(target, source)
--
  target = handles[target] || target
  target = nil if target == 0
  
  source = handles[source] || source
  source = source.kind_of?(Fixnum) ? "&#{source}" : " #{source}"
  
  append " #{target}<#{source}"
