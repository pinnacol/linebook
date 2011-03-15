Assign a file descriptor.
(target, source)
--
  target = handles[target] || target
  target = nil if target == 0
  
  source = handles[source] || source
  source = source.kind_of?(Fixnum) ? "&#{source}" : " #{source}"
  
  if chain?
    rewrite(CHECK_STATUS) {|m| " #{target}<#{source}#{m[1]}" }
  else
    writeln " #{target}<#{source}"
  end
  