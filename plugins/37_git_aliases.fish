# Status
alias gst='git status'
alias gss='git status -s'

# Diff
alias gsd='git diff'

# Pull and push
alias gl='git pull'
alias glr='git pull --rebase'

# Committing
alias gc='git commit -m'
alias gcs='git commit -s -m'
alias gcn='git commit -n -m'
alias gcns='git commit -s -n -m'
alias gce='git commit'
alias gces='git commit -s'
alias gcen='git commit -n'
alias gcens='git commit -s -n'
alias gca='git commit -a -m'
alias gcas='git commit -s -a -m'
alias gcan='git commit -n -a -m'
alias gcans='git commit -s -n -a -m'
alias gcae='git commit -a -e'
alias gcaes='git commit -s -a -e'
alias gcaen='git commit -a -e -n'
alias gcaens='git commit -s -a -e -n'
alias gcf='git commit -n -m fixup'
alias gcfs='git commit -s -n -m fixup'
alias gcaf='git commit -a -n -m fixup'
alias gcafs='git commit -s -a -n -m fixup'
alias gcw='git commit -n -m wip'
alias gcws='git commit -s -n -m wip'
alias gcaw='git commit -a -n -m wip'
alias gcaws='git commit -s -a -n -m wip'

# Checkout
alias gco='git checkout'
alias gcot='git checkout --track'
alias gcom='git checkout $(g_default_branch)'
alias gcob='git checkout -b'

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
alias gcps='git cherry-pick --skip'

# Branch
alias gb='git branch'
alias gbc='git branch --show-current'
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

# Finding
alias gf='git ls-files | grep'
