(command, *args)
--
  if args.last.kind_of?(Hash)
    opts = args.pop
    args = format_opts(opts) + args
  end
  cmd command, *args
  