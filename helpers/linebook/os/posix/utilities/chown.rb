Change the file ownership.

(owner, *files)
--
  unless owner.nil?
    execute 'chown', owner, *files
  end