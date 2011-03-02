(command, *args)
--
  if args.last.kind_of?(Hash)
    opts = args.pop
    args = format_cmd_options(opts) + args
  end
  cmd command, *args
  