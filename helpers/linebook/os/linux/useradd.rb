Adds the user. Assumes the current user has root privileges. Typically more
reliable in conjunction with login rather than su; some systems prevent
root commands from being available for non-root users.
(name, options={}) 
--
  execute 'useradd', name, options
