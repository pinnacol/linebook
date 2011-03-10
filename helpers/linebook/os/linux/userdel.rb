Removes the user.
(name, options={}) 
--
  # TODO - look into other things that might need to happen before:
  # * kill processes belonging to user
  # * remove at/cron/print jobs etc. 
  execute 'userdel', name, options
