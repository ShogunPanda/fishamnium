#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

set -x -g PATH ./node_modules/.bin $PATH

function ni --description "Install packages"
  npm install $argv
end

function nt --description "Runs npm test"
  npm test
end

function nr --description "Runs a script using npm"
  npm run $argv
end

function nrb --description "Builds code using npm run build"
  npm run $argv
end

function nrl --description "Lints code using npm run lint"
  npm run $argv
end

function nrf --description "Formats code using npm run format"
  npm run $argv
end

function nrd --description "Deploys code using npm run deploy"
  npm run $argv
end

function nrdf --description "Deploys code using npm run deploy:full"
  npm run $argv
end
