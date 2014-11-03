#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

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

function git_full_branch_name --description "Prints the GIT full branch name"
  git symbolic-ref HEAD ^ /dev/null; or git rev-parse --short HEAD ^ /dev/null
end

function git_full_branch_name_copy --description "Copies the GIT full branch name into the clipboard"
  git_full_branch_name | tr -d "\n" | pbcopy
end

function git_branch_name --description "Prints the GIT branch name"
  git_full_branch_name | sed -E "s#refs/heads/##"
end

function git_branch_name_copy --description "Copies the GIT branch name into the clipboard"
  git_branch_name | tr -d "\n" | pbcopy
end

function git_task --description "Prints the GIT task number"
  git_branch_name | sed -E "s/(.+)-([0-9]+)\$/\2/g";
end

function git_task_copy --description "Copies the GIT task number into the clipboard"
  git_task | tr -d "\n" | pbcopy
end

function git_commit_with_task --description "Commits a message appending the task number"
  set -l task (git_task)

  if [ (count $argv) -eq 1 ]
    set message $argv[1]
    set args ""
  else
    set message $argv[-1]
    set args $argv[1..-2]
  end


  git commit $args -m "$message [#$task]"
end