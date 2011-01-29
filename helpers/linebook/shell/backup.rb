Backup a file.
(path, options={})
  backup_path = "#{path}.bak"
--
  if options[:mv]
    mv_f path, backup_path
  else
    cp_f path, backup_path
  end
  
  chmod 644, backup_path
