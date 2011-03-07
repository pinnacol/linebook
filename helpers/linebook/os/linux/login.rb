(user='root', &block)
--
  target_name = guess_target_name(user)
  path = capture_path(target_name, &block)
  chmod 744, path
  sudo path, :E => false, :i => true, :u => user
