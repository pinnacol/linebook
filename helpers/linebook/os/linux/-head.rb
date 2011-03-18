require 'linebook/os/unix'
include Unix

def capture_script(options={})
  unless options.kind_of?(Hash)
    options = {:target_name => guess_target_name(options)}
  end

  target_name = options[:target_name] || guess_target_name('script')
  path = capture_path(target_name, options[:mode] || 0770) { yield }

  owner, group = options[:owner], options[:group]
  if owner || group
    callback 'before' do
      chown owner, group, path
    end
  end

  path
end
