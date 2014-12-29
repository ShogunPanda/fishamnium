#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# Set defaults
set -x -g FISHAMNIUM_VERSION "1.9.1"
[ (count $FISHAMNIUM_PLUGINS) -eq 0 ]; and set -x FISHAMNIUM_PLUGINS (/bin/ls ~/.fishamnium/plugins/*.fish | xargs -n1 basename);
[ (count $FISHAMNIUM_COMPLETIONS) -eq 0 ]; and set -x FISHAMNIUM_COMPLETIONS (/bin/ls ~/.fishamnium/completions/*.fish | xargs -n1 basename);
test -n $FISHAMNIUM_THEME; and set -x FISHAMNIUM_THEME default;

# Load plugins files
for i in $FISHAMNIUM_PLUGINS;
  set source ~/.fishamnium/plugins/$i
  test -x $source; and . $source
end

# Load completions files
for i in $FISHAMNIUM_COMPLETIONS;
  set source ~/.fishamnium/completions/$i
  test -x $source; and . $source
end

# Load theme
if test -x ~/.fishamnium/themes/$FISHAMNIUM_THEME.fish;
  . ~/.fishamnium/themes/$FISHAMNIUM_THEME.fish
end
