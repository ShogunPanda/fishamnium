#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#


complete -x -c fishamnium_bookmarks -n "__fishamnium_completion_is_global" -a "read get show load r g" -d "Reads a bookmark"
complete -f -c fishamnium_bookmarks -n "__fishamnium_completion_is_command read get show load r g" -a "(fishamnium_bookmarks l -a)" -d "Bookmark name"
complete -x -c fishamnium_bookmarks -n "__fishamnium_completion_is_global" -a "write set save store w s" -d "Writes a bookmark"
complete -f -c fishamnium_bookmarks -n "__fishamnium_completion_is_command write set save store w s" -a "(fishamnium_bookmarks l -a)" -d "Bookmark name"
complete -x -c fishamnium_bookmarks -n "__fishamnium_completion_is_global" -a "delete erase remove d e" -d "Deletes a bookmark"
complete -f -c fishamnium_bookmarks -n "__fishamnium_completion_is_command delete erase remove d e" -a "(fishamnium_bookmarks l -a)" -d "Bookmark name"
complete -x -c fishamnium_bookmarks -n "__fishamnium_completion_is_global" -a "list all l a" -d "Lists all bookmarks"
complete -c fishamnium_bookmarks -n "__fishamnium_completion_is_command list all l a" -s n -l names-only -d "Only list bookmarks names"
complete -c fishamnium_bookmarks -n "__fishamnium_completion_is_command list all l a" -s a -l autocomplete -d "Only list bookmarks name and description for autocompletion"
