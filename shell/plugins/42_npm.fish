#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

set -x -g PATH ./node_modules/.bin $PATH

function ni --description "Install packages"
  npm install $argv
end

function nr --description "Runs a script using npm"
  npm run $argv
end

function nt --description "Runs tests using npm"
  npm test
end