Makes a redirect statement.
(source, target)
--
  source = handles[source] || source
  source = nil if source == 1
  source = source.nil? || source.kind_of?(Fixnum) ? source : "#{source} "
  
  target = handles[target] || target
  target = target.kind_of?(Fixnum) ? "&#{target}" : " #{target}"
  
  append " #{source}>#{target}"
  