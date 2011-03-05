(user='root', &block)
--
  target_name = guess_target_name(user)
  path = capture_path(target_name, &block)
  chown user, nil, path
  chmod 744, path
  sudo path, :E => true, :u => user
  