#!/usr/bin/env fish
#
# This file is part of shamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

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

  # GIT
  set git_prompt ""
  set -l git_summary (~/.fishamnium/helpers/fishamnium git summary)
  if [ "$git_summary" != "" ]
    set git_summary (string split " " $git_summary)
    string match -r "^true" $git_summary[3] > /dev/null && set git_status $red "✗"; or set -l git_status $green "✔"
    set git_prompt (printf ' %s(%s) %s%s%s' $branch $git_summary[1] $git_status[1] $git_status[2] $normal)
  end

  # User colors
  set -l user (whoami)
  set user_color $green
  set symbol "%"

  if [ "$user" = "root" ]
    set symbol "\$"
    set user_color $red
  end

  # Build prompt
  set long_prompt (printf '%s[%s%s@%s%s] %s%s%s %s%s> %s' $yellow $user_color $user (hostname -s) $yellow $dir (basename (pwd)) $git_prompt $yellow $symbol $normal)
  set short_prompt (printf '%s[%s%s@%s%s] %s%s %s%s> %s' $yellow $user_color $user (hostname -s) $yellow $dir (basename (pwd)) $yellow $symbol $normal)

  set -l clean_long_prompt (__clean_prompt $long_prompt)

  if test (math $COLUMNS-(string length $clean_long_prompt)) -gt 0
    echo $long_prompt
  else
    echo $short_prompt
  end
end
