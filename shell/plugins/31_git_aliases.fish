#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

# Status
alias g='~/.fishamnium/helpers/fishamnium git'
alias gst='git status'
alias gss='git status -s'

# Diff
alias gd='git diff'

# Pull and push
alias gl='git pull'
alias gp='git push'
alias glr='git pull --rebase'

# Committing
alias gc='git commit -m'
alias gca='git commit -a -m'

# Checkout
alias gco='git checkout'
alias gcd='git checkout development'
alias gcm='git checkout master'
alias gcb='git checkout -b'

# Remote
alias gr='git remote'
alias grv='git remote -v'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grup='git remote update'

# Rebase
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbs='git rebase --skip'

# Cherry pick
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gcpa='git cherry-pick --abort'

# Branch
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -D'
alias gbm='git branch -m'

# Config
alias gcl='git config --list'

# Log
alias glo='git log --oneline'
alias glog='git log --oneline --graph'

# Add and merge
alias ga='git add'
alias gaa='git add -A'
alias gme='git merge'
alias gmt='git mergetool --no-prompt'
alias gmf='git merge --no-ff'

# Resetting
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gclean='git reset --hard && git clean -dfx'

# Finding
alias gf='git ls-files | grep'
