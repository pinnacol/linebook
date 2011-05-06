Change the file group ownership

(group, *files)
--
  unless group.nil?
    execute 'chgrp', group, *files
  end
  