Switches to a different user for the duration of a block.
(user='root', &block)
--
  target_name = guess_target_name(user)
  path = capture_path(target_name, &block)
  chmod '+x', path
  sudo path, :E => true, :u => user