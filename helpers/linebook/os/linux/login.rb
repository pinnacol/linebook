Logs in as the specified user for the duration of a block (the current ENV
and pwd are not preserved).
(user='root', &block)
--
  target_name = guess_target_name(user)
  path = capture_path(target_name, 0700, &block)
  execute 'su', user, path, :l => true
  