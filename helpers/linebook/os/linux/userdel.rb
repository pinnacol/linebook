Removes the user. Assumes the current user has root privileges. Typically more
reliable in conjunction with login rather than su; some systems prevent
root commands from being available for non-root users.
(name, options={}) 
--
  # TODO - look into other things that might need to happen before:
  # * kill processes belonging to user
  # * remove at/cron/print jobs etc. 
  execute 'userdel', name, options
