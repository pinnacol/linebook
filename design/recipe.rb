########################################################################
# Setup
#
# For recipes, declare assumptions and build everything else from there.
# You have to assume something.  Then you probably want to load/inherit
# some standard things.
#
# In general, don't get too far away from the command line.  Let this
# be a learning tool as much as it is a utility.
#
########################################################################
shebang

# check assumptions or exit
assume cmd
assume_user

# Creates a new script and has access to the local environment during compile.
# For clarity the new script also inherits the local scripting environment by
# default.
#
# Note that functions are not in general exportable. Therefore make shared
# functionality into bin scripts and add to PATH, which is exportable and may
# be preserved. (shebang)

# su -m user
# su user, :preserve_environment => true {}
as user do
  
end

# su -l user
# su user, :login => true {}
login user do
  
end

# Recipes should in general NOT inherit the local env because they are
# constructed independently of it.  Recipes may declare assumptions to check,
# but that's just a nicety.  The main thing recipes need to know, however, is
# the package directory.  From there they can determine the path to any
# package resources (bin scripts, files, recipes, etc).
#
# The basic assumption is that they will be executed by a user who has logged
# in.  The login environment is the starting environment for the recipe such
# that to run/debug manually:
#
#   su -l user
#   LINECOOK_PACKAGE_DIR=package_dir ./path/to/recipe
#
# The login gets you the shell you need, and the basic environment (via
# profiles). The reason for this setup is that it's easy to debug, not that
# there aren't other alternatives.
#
# In the run script, any special environments should be set up.  Ex: create
# the users you need, with their shells/env.  And setup any su permissions:
#
#   # http://cosminswiki.com/index.php/How_to_let_users_su_without_password
#   groupadd wheel
#   usermod -G wheel <username>
#   # them modify pam.d
#

# def env(env, cmd=nil)
#   print "env -i #{format_env(env)} "
#   puts cmd if cmd
# end
#
# env -i su -l user
env('LINECOOK_PACKAGE_DIR' => '$LINECOOK_PACKAGE_DIR').su user, :login => true do

end