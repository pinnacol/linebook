(*args)
--
  if args.empty?
    target << 'sudo '
  else
    execute 'sudo', *args
  end
  