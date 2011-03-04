Returns the current system time.  A format string may be provided, as well as
a hash of command line options.
(format=nil, options={})
--
  if format
    format = quote("+#{format}")
  end
  
  cmd "date", format, options