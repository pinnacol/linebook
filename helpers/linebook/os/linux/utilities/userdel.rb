Delete a user account and related files.

(login, options={}) 
--
  # TODO - look into other things that might need to happen before:
  # * kill processes belonging to user
  # * remove at/cron/print jobs etc. 
  execute 'userdel', login, options
