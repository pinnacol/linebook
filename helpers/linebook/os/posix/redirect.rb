Makes a redirect statement.
(source, target)
--
  source = handles[source] || source
  source = nil if source == 1
  source = source.nil? || source.kind_of?(Fixnum) ? source : "#{source} "
  
  target = handles[target] || target
  target = target.kind_of?(Fixnum) ? "&#{target}" : " #{target}"
  
  if chain?
    rewrite(CHECK_STATUS) {|m| " #{source}>#{target}#{m[1]}" }
  else
    writeln " #{source}>#{target}"
  end
