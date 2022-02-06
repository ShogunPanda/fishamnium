#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

set -x -g PATH ./node_modules/.bin $PATH

alias ni="npm install"
alias nid="npm install -D"
alias nr="npm run"
alias nt="npm test"
alias nrb="npm run build"
alias nrf="npm run format"
alias nrl="npm run lint"
alias nrd="npm run deploy"
alias no="npm outdated"

alias pni="pnpm install"
alias pna="pnpm add"
alias pnad="pnpm add -D"
alias pnr="pnpm run"
alias pnt="pnpm test"
alias pnrb="pnpm run build"
alias pnrf="pnpm run format"
alias pnrl="pnpm run lint"
alias pnrd="pnpm run deploy"
alias pno="pnpm outdated"