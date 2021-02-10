#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function fishamnium_conditional_load --description "Conditionally load plugins"
  which $argv[1] > /dev/null ^ /dev/null && chmod u+x ~/.fishamnium/plugins/$argv[2].fish; or chmod u-x ~/.fishamnium/plugins/$argv[2].fish  
end

# Set defaults
set -x -g FISHAMNIUM_VERSION "8.5.1"

[ (count $FISHAMNIUM_PLUGINS) -eq 0 ] && set -x FISHAMNIUM_PLUGINS (/bin/ls ~/.fishamnium/plugins/*.fish | xargs -n1 basename)
[ (count $FISHAMNIUM_COMPLETIONS) -eq 0 ] && set -x FISHAMNIUM_COMPLETIONS (/bin/ls ~/.fishamnium/completions/*.fish | xargs -n1 basename)
test -n $FISHAMNIUM_THEME && set -x FISHAMNIUM_THEME default

# Set path
for root in /usr/local /opt /var
  for dir in $root/bin $root/sbin
    test -d $dir && set -x -g PATH $dir $PATH
	end
end

set -x -g PATH $PATH ~/.fishamnium/helpers

# Conditionally load plugins
fishamnium_conditional_load n 41_node
fishamnium_conditional_load npm 42_npm
fishamnium_conditional_load rbenv 51_ruby
fishamnium_conditional_load bundle 52_bundler
fishamnium_conditional_load rails 53_rails

# Load plugins files
set -e -g FISHAMNIUM_LOADED_PLUGINS
for i in (string split " " "$FISHAMNIUM_PLUGINS")
  set source ~/.fishamnium/plugins/$i
  test -x $source && set -x -g FISHAMNIUM_LOADED_PLUGINS $FISHAMNIUM_LOADED_PLUGINS $i
  test -x $source && . $source
end

# Load completions files
set -e -g FISHAMNIUM_LOADED_COMPLETIONS
for i in (string split " " "$FISHAMNIUM_COMPLETIONS")
  set source ~/.fishamnium/completions/$i
  test -x $source && set -x  -g FISHAMNIUM_LOADED_COMPLETIONS $FISHAMNIUM_LOADED_COMPLETIONS $i
  test -x $source && . $source
end

# Load theme
if test -x ~/.fishamnium/themes/$FISHAMNIUM_THEME.fish
  . ~/.fishamnium/themes/$FISHAMNIUM_THEME.fish
end
