#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function n
  bash $N_PREFIX/bin/n $argv
  set --local n_exit $status
  node -v ^ /dev/null | sed -e "s#^v##" > $N_PREFIX/active 
  return $n_exit
end

set -x -g N_PREFIX /usr/local
set -x -g PATH $N_PREFIX/bin $PATH