Changes the file mode. The file mode may be specified as a String or a Fixnum.
If a Fixnum is provided, then it will be formatted into an octal string using
sprintf "%o".

(mode, file, options={})
--
  unless mode.nil?
    if mode.kind_of?(Fixnum)
      mode = sprintf("%o", mode)
    end
    execute 'chmod', mode, file, options
  end