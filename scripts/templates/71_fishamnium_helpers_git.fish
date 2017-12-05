#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fishamnium_git_completion_is_global
  set cmd (commandline -opc)

  if [ (count $cmd) -eq 1 ]
    return 0
  else
    for c in $cmd[2..-1]
      switch $c
        # General options that can still take a command
        case "-n" "-v" "--dry-run" "--verbose"
          continue
        case "-V" "-h" "--version" "--help"
          return 1
        case "*"
          return 1
      end
    end
  end
end

function __fishamnium_git_completion_is_command
  set cmd (commandline -opc)

  if [ (count $cmd) -eq 1 ]
    return 1
  else
    for c in $cmd[2..-1]
      switch $c
        # General options that can still take a command on global
        case "-n" "-v" "--dry-run" "--verbose"
          continue
        case "-V" "-h" "--version" "--help"
          return 1
        case "*"
          [ "$c" = "$argv[1]" ]; and return 0; or return 1
      end
    end
  end
end
