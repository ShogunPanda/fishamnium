#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# TODO@PI: Rewrite me

function l --description "Show all bookmarks."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/fishamnium_bookmarks list $argv
end

function d_g --description "Change current directory to a saved bookmark."
  set -l OUTPUT (eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/fishamnium_bookmarks get $argv)
  [ $status = 0 ]; and cd "$OUTPUT"
end

function d_s --description "Saves the current directory as new bookmark."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/fishamnium_bookmarks save $argv
end

function d_d --description "Deletes an existing bookmark."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/fishamnium_bookmarks delete $argv
end
