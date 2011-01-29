Installs a template from the package.
(target, options={})
--
  template_name = options[:source] || File.basename(target)
  locals = options[:locals] || {}
  
  source = template_path(template_name, locals)
  install(source, target, options)