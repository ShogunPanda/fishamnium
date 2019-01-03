#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#


function e --description "Edits a bookmark using the current terminal editor."
  set -l OUTPUT (b $argv)
  [ $status = 0 ] && eval $EDITOR "$OUTPUT"
end

function c --description "Change current directory to a saved bookmark."
  set -l OUTPUT (b $argv)
  [ $status = 0 ] && cd "$OUTPUT"
end

function o --description "Edits a bookmark using the current editor."
  set -l OUTPUT (b $argv)
  [ $status = 0 ] && eval $GEDITOR "$OUTPUT"
end

alias l='~/.fishamnium/helpers/fishamnium bookmarks list'
alias b='~/.fishamnium/helpers/fishamnium bookmarks show'
alias s='~/.fishamnium/helpers/fishamnium bookmarks save'
alias d='~/.fishamnium/helpers/fishamnium bookmarks delete'
