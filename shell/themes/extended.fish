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
    [ "$rv" = "$old_rv" ] && break
  end

  echo $rv
end

function __clean_prompt
  string replace -a -r '(\x1b|\e|\033)\[\d{1,3}(;\d{1,3})*[mGK]?' '' $argv[1]
end

function fish_prompt -d "Write out the prompt"
  # Terminal codes
  # set -l white (set_color -o white)
  # set -l yellow (set_color -o yellow)
  # set -l green (set_color -o green)
  # set -l red (set_color -o red)
  # set -l black (set_color -o black)
  # set -l dir (set_color -o blue)
  # set -l branch (set_color -o magenta)
  # set -l commit (set_color magenta)

  # RGB Codes
  set -l white (set_color -o FFFFFF)
  set -l yellow (set_color FFDF00)
  set -l green (set_color -o 00CC00)
  set -l red (set_color -o CC0000)
  set -l black (set_color -o 000000)
  set -l dir (set_color 5FAFFF)
  set -l branch (set_color -o AF5FFF)
  set -l commit (set_color -o AF87AF)
  set -l normal (set_color normal)

  # --- Upper prompt ---
  # Date
  set -l upper_prompt (printf '%s[%s%s%s]%s' $yellow $white (date "+%Y-%m-%d %H:%M:%S") $yellow)

  # Current directory
  set upper_prompt (printf '%s %s%s' $upper_prompt $dir (pwd |sed -e "s#$HOME#~#"))

  # GIT
  set -l git_summary (~/.fishamnium/helpers/fishamnium git summary)
  if [ "$git_summary" != "" ]
    set git_summary (string split " " $git_summary)
    string match -r "^true" $git_summary[3] > /dev/null && set git_status $red "✗"; or set -l git_status $green "✔"
    set upper_prompt (printf '%s %s(%s %s%s%s) %s%s' $upper_prompt $branch $git_summary[1] $commit $git_summary[2] $branch $git_status[1] $git_status[2])
  end

  # --- Lower prompt ---
  set -l user (whoami)
  set user_color $green
  set symbol "%"

  if [ "$user" = "root" ]
    set symbol "\$"
    set user_color $red
  end

  # User and host
  set lower_prompt (printf '%s[%s%s@%s' $yellow $user_color $user (hostname -s))

  # Ruby
  if [ "$FISHAMNIUM_THEME_SHOW_RUBY" != "" ]
    if contains "51_ruby.fish" $FISHAMNIUM_LOADED_PLUGINS
      set -l current_ruby (cat ~/.rbenv/version ^ /dev/null)
      [ "$current_ruby" != "" ] && set lower_prompt (printf '%s %sruby:%s' $lower_prompt $black $current_ruby)
    end
  end

  # Node.js
  if [ "$FISHAMNIUM_THEME_SHOW_NODE" != "" ]
    if contains "41_node.fish" $FISHAMNIUM_LOADED_PLUGINS
      set -l current_node (cat $N_PREFIX/n/active ^ /dev/null)
      [ "$current_node" != "" ] && set lower_prompt (printf '%s %snode:%s' $lower_prompt $black $current_node)
    end
  end

  # Shell symbol and end
  set lower_prompt (printf '%s%s] %s> %s' $lower_prompt $yellow $symbol $normal)
  set short_prompt (printf '%s[%s%s@%s%s] %s%s %s%s> %s' $yellow $user_color $user (hostname -s) $yellow $dir (basename (pwd)) $yellow $symbol $normal)

  set -l clean_upper_prompt (__clean_prompt $upper_prompt)
  set -l clean_lower_prompt (__clean_prompt $lower_prompt)

  if test (math $COLUMNS-(string length $clean_lower_prompt)) -gt (string length $clean_upper_prompt)
    printf '%s\n%s' $upper_prompt $lower_prompt
  else
    echo $short_prompt
  end
end
