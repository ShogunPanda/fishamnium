#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fishamnium_completion_is_global
  set cmd (commandline -opc)

  if test (count $cmd) -eq 1
    return 0
  # General options
  else if contains $cmd[2] "-n" "-v" "-q" "-h" "--dry-run" "--verbose" "--quiet" "--version" "--help"
    return 0
  else
    return 1
  end
end

function __fishamnium_completion_is_command
  set cmd (commandline -opc)

  if test (count $cmd) -eq 1
    return 1
  else
    for c in $cmd[2..-1]
      if contains $cmd[2] "-n" "-v" "-q" "-h" "--dry-run" "--verbose" "--quiet" "--version" "--help"
        continue
      else if contains $c $argv
        return 0
      else
        return 1
      end
    end
  end
end

complete -c fishamnium_bookmarks -e
complete -c fishamnium_git -e
