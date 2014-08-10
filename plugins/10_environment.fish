#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

set -x -g EDITOR "nano"
set -x -g fish_greeting

function fishamnium_reload --description "Reloads Fishamnium"
  echo "Reloading Fishamnium ..."
  . ~/.fishamnium/loader.fish  
end

