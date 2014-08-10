#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function fishamnium_install_git_aliases
  if which rvm-prompt > /dev/null;
    git config --global alias.fbn '! git symbolic-ref HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null'
    git config --global alias.bn '! git fbn | sed "s#refs/heads/##"'
    git config --global alias.task '! git bn | sed -E "s/(.+)-([0-9]+)$/\2/g"'
  end
end

function is_git_repository --description "Check if the current directory is inside a GIT repository."
  git rev-parse --is-inside-work-tree > /dev/null ^ /dev/null
end

function git_current_branch --description "Show the current branch of a GIT repository."
  if is_git_repository
    set ref (git symbolic-ref HEAD ^ /dev/null; or git rev-parse --short HEAD ^ /dev/null)
    echo $ref | sed -E "s#refs/heads/##g"
  end
end

function git_current_repository --description "Show the current local and remote repository of a GIT repository."
  if is_git_repository
    echo (git remote -v | cut -d':' -f 2)
  end
end

function git_log_prettify --description "Show a pretty GIT log."
  git log --pretty $argv
end

function git_branch
  set branch (gbn ^ /dev/null)
  test -n $branch; and echo $branch
end

function git_sha
  set sha (git rev-parse --short HEAD ^ /dev/null)
  test -n $sha; and echo $sha
end

function git_push_and_pull
  git pull $argv; and git push $argv
end

function gfbn --description "Prints the GIT full branch name"
  git symbolic-ref HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
end

function gfbnc --description "Copies the GIT full branch name into the clipboard"
  gfbn | tr -d "\n" | pbcopy
end

function gbn --description "Prints the GIT branch name"
  gfbn | sed \"s#refs/heads/##\""
end

function gbnc --description "Copies the GIT branch name into the clipboard"
  gbn | tr -d "\n" | pbcopy
end

function gt --description "Prints the GIT task number"
  git branch-name | sed -E \"s/(.+)-([0-9]+)$/\\\\2/g\";
end

function gtc --description "Copies the GIT task number into the clipboard"
  gt | tr -d "\n" | pbcopy
end