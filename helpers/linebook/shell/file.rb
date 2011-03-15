Installs a file from the package.
(file_name, target, options={})
  source = file_path(file_name, guess_target_name(target))
  options = {:D => true}.merge(options)
--
  install(source, target, options)