Installs a template from the package.
(template_name, target, options={})
  locals = options.delete(:locals) || {}
  source = template_path(template_name, guess_target_name(target), 0600, locals)
  options = {:D => true}.merge(options)
--
  install(source, target, options)