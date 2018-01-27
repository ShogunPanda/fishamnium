#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fishamnium_complete
  set cmd (commandline -pc)

  # This is invocated as g
  set cmd (string replace -r "^(~/\\.fishamnium/helpers/fishamnium)|g" "fishamnium git" "$cmd")

  # Add fishamnium to the argv
  if test (count $argv) -gt 0
    set regexp "^(\\s*fishamnium\\s+$argv[1])\$"
  else
    set regexp "^(\\s*fishamnium\\s+\\S*)\$"
  end

  string match -r "$regexp" "$cmd"
  set match $status # Do not directly return $status since we might want to insert a echo statement below for debugging
  return $match
end

complete -c g -e
complete -c fishamnium -e
complete -x -c fishamnium -n "__fishamnium_complete" -a "bookmarks" -d "Manage bookmarks"
complete -x -c fishamnium -n "__fishamnium_complete" -a "git" -d "Manage GIT repository"
