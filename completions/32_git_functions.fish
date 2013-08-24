#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# Pull and push
complete -c git -n "__fish_git_using_command pull" -f -a "(__fish_git_heads) (__fish_git_remotes)"
complete -c git -n "__fish_git_using_command push" -f -a "(__fish_git_heads) (__fish_git_remotes)"
for i in gl gp glp glr;
  complete -c $i -f -a "(__fish_git_heads) (__fish_git_remotes)";
end;

# Checkout
complete -c gco -f -a '(__fish_git_branches)' --description 'Branch'
complete -c gco -f -a '(__fish_git_tags)' --description 'Tag'

# Remote
for i in gr grv grmv grrm grset grup;
  complete -f -c $i -a '(__fish_git_remotes)'
end

# Rebase
for i in grbi grbc grba;
  complete -c $i -f -a "(__fish_git_heads)";
end;