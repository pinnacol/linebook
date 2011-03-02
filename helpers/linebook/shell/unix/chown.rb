Makes a command to chown a file or directory.
(user, group, target)
--
  if user || group
    execute 'chown', "#{user}:#{group}", target
  end
  