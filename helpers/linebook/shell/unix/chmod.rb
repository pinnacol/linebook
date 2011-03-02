Makes a command to chmod a file or directory.  Provide the mode as the
literal string that should go into the statement:

  chmod "600" target

(mode, target)
--
  if mode
    execute 'chmod', mode, target
  end