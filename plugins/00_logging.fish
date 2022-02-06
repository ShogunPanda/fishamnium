#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function __fishamnium_print_error
  echo -e "\x1b[31m$argv\x1b[0m"
  return 1
end