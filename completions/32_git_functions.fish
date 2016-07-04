#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fish_command_index
  set -l cmd (commandline -opc)

  if test (count $cmd) -eq $argv[1]
    return 0
  else
    return 1
  end
end

# Pull and push
complete -c git -n "__fish_git_using_command pull" -f -a "(__fish_git_heads) (__fish_git_remotes)"
complete -c git -n "__fish_git_using_command push" -f -a "(__fish_git_heads) (__fish_git_remotes)"
for i in gl gp glp glr
  complete -c $i -f -a "(__fish_git_heads) (__fish_git_remotes)"
end

# Checkout
for i in gco gcb
  complete -c $i -f -a '(__fish_git_branches)' --description 'Branch'
  complete -c $i -f -a '(__fish_git_tags)' --description 'Tag'
end

# Branch related
for i in gb gbd gbm gme gmt gmf
  complete -c $i -f -a '(__fish_git_branches)' --description 'Branch'
  complete -c $i -f -a '(__fish_git_tags)' --description 'Tag'
end

# Remote
for i in gr grv grmv grrm grset grup
  complete -c $i -f -a '(__fish_git_remotes)'
end

# Rebase
for i in grbi grbc grba
  complete -c $i -f -a "(__fish_git_heads)"
end

# Workflow
complete -c g_default_branch -n "__fish_command_index 1" -f -a "(__fish_git_branches)" --description "Branch"
complete -c g_default_remote -n "__fish_command_index 1" -f -a "(__fish_git_remotes)" --description "Remote"
complete -c g_delete -f -a "(__fish_git_branches)" --description "Branch"

for i in g_start g_release
  complete -c $i -n "__fish_command_index 2" -f -a "(__fish_git_branches)" --description "Branch"
  complete -c $i -n "__fish_command_index 3" -f -a "(__fish_git_remotes)" --description "Remote"
end

for i in g_refresh g_finish g_full_finish
  complete -c $i -n "__fish_command_index 1" -f -a "(__fish_git_branches)" --description "Branch"
  complete -c $i -n "__fish_command_index 2" -f -a "(__fish_git_remotes)" --description "Remote"
end
