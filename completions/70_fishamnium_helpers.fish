#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# Bookmarks
complete -c b -f -a '(~/.fishamnium/helpers/fishamnium_bookmarks list --names-only)'
complete -c c -f -a '(~/.fishamnium/helpers/fishamnium_bookmarks list --names-only)'
complete -c d -f -a '(~/.fishamnium/helpers/fishamnium_bookmarks list --names-only)'
complete -c e -f -a '(~/.fishamnium/helpers/fishamnium_bookmarks list --names-only)'
complete -c o -f -a '(~/.fishamnium/helpers/fishamnium_bookmarks list --names-only)'

# GIT
complete -c g -f -a '(~/.fishamnium/helpers/fishamnium_git list-commands)'

