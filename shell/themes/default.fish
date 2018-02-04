#!/usr/bin/env fish
#
# This file is part of shamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function __truncated_cwd
  set -l rv (pwd |sed -e "s#$HOME#~#")
  set -l old_rv ""
  set len 50

  while [ (echo -e $rv | wc -m)  -gt $len ]
    set old_rv $rv
    set rv (echo $rv | sed -E "s#^((…)?[^/]*/)#…/#")
    [ "$rv" = "$old_rv" ]; and break
  end

  echo $rv
end

function fish_prompt -d "Write out the prompt"
  # Terminal codes
  set -l white (set_color -o white)
  set -l yellow (set_color -o yellow)
  set -l green (set_color -o green)
  set -l red (set_color -o red)
  set -l black (set_color -o black)
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
	printf '%s[%s%s%s]%s' $yellow $white (date "+%Y-%m-%d %H:%M:%S") $yellow

  # Current directory
  printf ' %s%s' $dir (pwd |sed -e "s#$HOME#~#")

  # GIT
  set -l git_summary (~/.fishamnium/helpers/fishamnium git summary)
  if [ "$git_summary" != "" ]
    set -l git_summary (string split " " $git_summary)
    string match -r "^true" $git_summary[3] > /dev/null; and set git_status $red "✗"; or set -l git_status $green "✔"
    printf ' %s(%s %s%s%s) %s%s' $branch $git_summary[1] $commit $git_summary[2] $branch $git_status[1] $git_status[2]
  end

  # User and host
  printf '\n%s[%s%s@%s' $yellow $user_color $user (hostname -s)

  # Ruby
  if [ "$FISHAMNIUM_THEME_SHOW_RUBY" != "" ]
    if contains "51_ruby.fish" $FISHAMNIUM_LOADED_PLUGINS
      set -l current_ruby (cat ~/.rbenv/version ^ /dev/null)
      [ "$current_ruby" != "" ]; and printf ' %sruby:%s' $black $current_ruby
    end
  end

  # Node.js
  if [ "$FISHAMNIUM_THEME_SHOW_NODE" != "" ]
    if contains "41_node.fish" $FISHAMNIUM_LOADED_PLUGINS
      set -l current_node (cat $N_PREFIX/active ^ /dev/null)
      [ "$current_node" != "" ]; and printf ' %snode:%s' $black $current_node
    end
  end

  # Shell symbol and end
  printf '%s] %s> %s' $yellow $symbol (set_color normal)
end
