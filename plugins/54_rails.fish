#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function rc --description "Starts the rails console"
  rails console $argv
end

function rs --description "Starts the rails server"
  rails server $argv
end

