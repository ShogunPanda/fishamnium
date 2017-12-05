#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function g_summary --description "Gets a summary of current GIT repository branch, SHA and dirty status."
  ~/.fishamnium/helpers/fishamnium_git summary
end

function g_is_repository --description "Check if the current directory is inside a GIT repository."
  ~/.fishamnium/helpers/fishamnium_git is_repository
end

function g_is_dirty --description "Check if the current working tree has uncommited changes."
  ~/.fishamnium/helpers/fishamnium_git is_dirty
end

function g_branch --description "Show the current branch of a GIT repository."
  eval ~/.fishamnium/helpers/fishamnium_git branch_name
end

function g_remotes --description "Show all the remotes of a GIT repository."
  eval ~/.fishamnium/helpers/fishamnium_git remotes
end

function g_log_prettify --description "Show a pretty GIT log."
  git log --pretty $argv
end

function g_sha
  eval ~/.fishamnium/helpers/fishamnium_git sha
end

function g_full_branch_name --description "Prints the GIT full branch name"
  eval ~/.fishamnium/helpers/fishamnium_git full_branch_name
end

function g_full_branch_name_copy --description "Copies the GIT full branch name into the clipboard"
  eval ~/.fishamnium/helpers/fishamnium_git full_branch_name | pbcopy
end

function g_branch_copy --description "Copies the GIT branch name into the clipboard"
  eval ~/.fishamnium/helpers/fishamnium_git branch_name | pbcopy
end

function g_task --description "Prints the GIT task number"
  eval ~/.fishamnium/helpers/fishamnium_git task
end

function g_task_copy --description "Copies the GIT task number into the clipboard"
  eval ~/.fishamnium/helpers/fishamnium_git task | pbcopy
end

function g_commit_with_task --description "Commits a message appending the task number"
  eval ~/.fishamnium/helpers/fishamnium_git commit_with_task $argv
end

function g_reset --description "Cleans up a local branch."
  eval ~/.fishamnium/helpers/fishamnium_git reset $argv
end

function g_delete --description "Deletes a branch locally and remotely."
  eval ~/.fishamnium/helpers/fishamnium_git delete $argv
end

function g_cleanup --description "Removes all merged branch."
  eval ~/.fishamnium/helpers/fishamnium_git cleanup $argv
end

function g_start --description "Starts a new branch out of the base one."
  eval ~/.fishamnium/helpers/fishamnium_git start $argv
end

function g_refresh --description "Rebases the current branch on top of an existing remote branch."
  eval ~/.fishamnium/helpers/fishamnium_git refresh $argv
end

function g_finish --description "Merges a branch back to its base remote branch."
  eval ~/.fishamnium/helpers/fishamnium_git finish $argv
end

function g_full_finish --description "Merges a branch back to its base remote branch and then deletes the local copy."
  eval ~/.fishamnium/helpers/fishamnium_git full_finish $argv
end

function g_fast_commit --description "Creates a local branch, commit changes and then merges it back to the base branch."
  eval ~/.fishamnium/helpers/fishamnium_git fast_commit $argv
end

function g_pull_request --description "Sends a Pull Request and deletes the local branch."
  eval ~/.fishamnium/helpers/fishamnium_git pull_request $argv
end

function g_fast_pull_request --description "Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end."
  eval ~/.fishamnium/helpers/fishamnium_git fast_pull_request $argv
end

function g_release --description "Tags a release."
  eval ~/.fishamnium/helpers/fishamnium_git release $argv
end

function g_import --description "Imports latest changes to a local branch on top of an existing remote branch."
  eval ~/.fishamnium/helpers/fishamnium_git import $argv
end

function g_start_from_release --description "Starts a new branch out of a remote release branch."
  eval ~/.fishamnium/helpers/fishamnium_git start_from_release $argv
end

function g_refresh_from_release --description "Rebases the current branch on top of an existing remote release branch."
  eval ~/.fishamnium/helpers/fishamnium_git refresh_from_release $argv
end

function g_finish_to_release --description "Merges a branch back to its base remote release branch."
  eval ~/.fishamnium/helpers/fishamnium_git finish_to_release $argv
end

function g_full_finish_to_release --description "Merges a branch back to its base remote release branch and then deletes the local copy."
  eval ~/.fishamnium/helpers/fishamnium_git full_finish_to_release $argv
end

function g_delete_release --description "Deletes a release branch locally and remotely."
  eval ~/.fishamnium/helpers/fishamnium_git delete_release $argv
end

function g_import_release --description "Imports latest changes to a local branch on top of an existing remote release branch."
  eval ~/.fishamnium/helpers/fishamnium_git import_release $argv
end