Installs a template from the package.
(template_name, target, options={})
  locals = options[:locals] || {}
  source = template_path(template_name, guess_target_name(target), locals)
--
  install(source, target, options)