#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fish_bookmarks
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/fishamnium_bookmarks list --names-only
end

complete -c d_g -f -a '(__fish_bookmarks)'
complete -c d_d -f -a '(__fish_bookmarks)'
