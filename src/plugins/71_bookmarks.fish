#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function fishamnium_bookmarks --description "Manage bookmarks." --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  eval ~/.fishamnium/helpers/fishamnium_bookmarks $argv
end

function l --description "Show all bookmarks." --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  eval ~/.fishamnium/helpers/fishamnium_bookmarks list $argv
end

function b --description "Show a bookmark." --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  set -l OUTPUT (eval ~/.fishamnium/helpers/fishamnium_bookmarks get $argv)
  [ $status = 0 ]; and echo "$OUTPUT"
end

function e --description "Edits a bookmark using the current terminal editor."  --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  set -l OUTPUT (eval ~/.fishamnium/helpers/fishamnium_bookmarks get $argv)
  [ $status = 0 ]; and eval $EDITOR "$OUTPUT"
end

function c --description "Change current directory to a saved bookmark."  --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  set -l OUTPUT (eval ~/.fishamnium/helpers/fishamnium_bookmarks get $argv)
  [ $status = 0 ]; and cd "$OUTPUT"
end

function o --description "Edits a bookmark using the current editor."  --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  set -l OUTPUT (eval ~/.fishamnium/helpers/fishamnium_bookmarks get $argv)
  [ $status = 0 ]; and eval $GEDITOR "$OUTPUT"
end

function s --description "Saves the current directory as new bookmark."  --wraps ~/.fishamnium/helpers/fishamnium_bookmarks
  eval ~/.fishamnium/helpers/fishamnium_bookmarks save $argv
end

function d --description "Deletes an existing bookmark."
  eval ~/.fishamnium/helpers/fishamnium_bookmarks delete $argv
end
