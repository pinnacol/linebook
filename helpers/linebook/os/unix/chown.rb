Changes file ownership. A nil value as owner or group will preserve the
existing value.

(owner, group, file, options={})
--
  unless owner.nil? && group.nil?
    execute 'chown', "#{owner}:#{group}", file, options
  end