#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function bi --description "Install the bundle"
  bundle install $argv
end

function bu --description "Update the bundle"
  bundle update $argv
end

function be --description "Execute under the context of the bundle"
  bundle exec $argv
end

function bl --description "List the contents of the bundle"
  bundle list $argv
end

function bs --description "Show the location of a gem of the bundle"
  bundle show $argv
end

