#!/usr/bin/env fish
#
# This file is part of shamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __truncated_cwd
  set -l rv (pwd |sed -e "s#$HOME#~#")
  set -l old_rv ""
  set len 50

  while [ (echo -e $rv | wc -m)  -gt $len ];
    set old_rv $rv
    set rv (echo $rv | sed -E "s#^((\.\.\./)?[^/]*/)#.../#")
    [ "$rv" = "$old_rv" ]; and break;
  end;

  echo $rv
end

function fish_prompt -d "Write out the prompt"
  # Terminal codes
  set -l white (set_color -o white)
  set -l yellow (set_color -o yellow)
  set -l green (set_color -o green)
  set -l red (set_color -o red)
  set -l dir (set_color -o blue)
  set -l branch (set_color -o magenta)
  set -l commit (set_color magenta)

  # RGB Codes
  #set -l white (set_color -o ffffff)
  #set -l yellow (set_color ffdf00)
  #set -l green (set_color -o 00ff00)
  #set -l red (set_color -o ff0000)
  #set -l dir (set_color 5fafff)
  #set -l branch (set_color -o af5fff)
  #set -l commit (set_color -o af87af)

  set -l user (whoami)
  set user_color $green
  set symbol "%"

  if [ "$user" = "root" ]
    set symbol "\$"
    set user_color $red
  end

  # Date
	printf '%s[%s%s%s]%s' $yellow $white (date "+%Y-%m-%d %H:%M") $yellow

  # Current directory
  printf ' %s%s' $dir (__truncated_cwd)

  # GIT
  if is_git_repository
    printf ' %s(%s %s%s%s)' $branch (git_current_branch) $commit (git_sha) $branch

    if [ "(git status -s)" != "" ]
      printf ' %s✗' $red
    else
      printf ' %s✔' $green
    end
  end

  # User and host
  printf '\n%s[%s%s@%s' $yellow $user_color $user (hostname -s)

  # RVM
  set -l current_rvm (rvm_current)
  [ "$current_rvm" != "" ]; and printf ' %s%s' $red $current_rvm

  # Shell symbol and end
  printf '%s] %s> %s' $yellow $symbol (set_color normal)
end
