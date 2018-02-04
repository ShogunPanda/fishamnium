#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit/.
#

# All commands
complete -x -c fishamnium -n "__fishamnium_complete 'bookmarks\\s+\\S*'" -a "(fishamnium bookmarks autocomplete)"

# Bookmarks
complete -x -c fishamnium -n "__fishamnium_complete 'bookmarks\\s+(read|get|get|show|load|r|g)\\s+\\S*'" -a "(fishamnium bookmarks l -a)" -d "Bookmark name"
complete -x -c fishamnium -n "__fishamnium_complete 'bookmarks\\s+(write|set|save|store|w|s)\\s+\\S*'" -a "(fishamnium bookmarks l -a)" -d "Bookmark name"
complete -x -c fishamnium -n "__fishamnium_complete 'bookmarks\\s+(delete|erase|remove|d|e)\\s+\\S*'" -a "(fishamnium bookmarks l -a)" -d "Bookmark name"

# Listing
complete -f -c fishamnium -n "__fishamnium_complete 'bookmarks\\s+(list|all|l|a)\\s+\\S*'" -s n -l names-only -d "Only list bookmarks names"
complete -f -c fishamnium -n "__fishamnium_complete 'bookmarks\\s+(list|all|l|a)\\s+\\S*'" -s a -l autocomplete -d "Only list bookmarks name and description for autocompletion"

# Aliasing
complete -c b -e
complete -c e -e
complete -c c -e
complete -c o -e
complete -c d -e
complete -c l -e

complete -c b -x -a '(~/.fishamnium/helpers/fishamnium bookmarks l -a)'
complete -c e -x -a '(~/.fishamnium/helpers/fishamnium bookmarks l -a)'
complete -c c -x -a '(~/.fishamnium/helpers/fishamnium bookmarks l -a)'
complete -c o -x -a '(~/.fishamnium/helpers/fishamnium bookmarks l -a)'
complete -c s -x -a '(~/.fishamnium/helpers/fishamnium bookmarks l -a)'
complete -c d -x -a '(~/.fishamnium/helpers/fishamnium bookmarks l -a)'
complete -c l -s n -l names-only -d "Only list bookmarks names"
complete -c l -s a -l autocomplete -d "Only list bookmarks name and description for autocompletion"
