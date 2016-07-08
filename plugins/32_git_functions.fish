#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function is_git_repository --description "Check if the current directory is inside a GIT repository."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g is_repository
end

function git_branch --description "Show the current branch of a GIT repository."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g branch_name
end

function git_remotes --description "Show all the remotes of a GIT repository."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g remotes
end

function git_log_prettify --description "Show a pretty GIT log."
  git log --pretty $argv
end

function git_sha
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g sha
end

function git_full_branch_name --description "Prints the GIT full branch name"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g full_branch_name
end

function git_full_branch_name_copy --description "Copies the GIT full branch name into the clipboard"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g full_branch_name | pbcopy
end

function git_branch_copy --description "Copies the GIT branch name into the clipboard"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g branch_name | pbcopy
end

function git_task --description "Prints the GIT task number"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g task
end

function git_task_copy --description "Copies the GIT task number into the clipboard"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g task | pbcopy
end

function git_commit_with_task --description "Commits a message appending the task number"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g commit_with_task $argv
end

function g_start --description "Starts a new branch off a remote existing branch (default development)."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g start $argv
end

function g_refresh --description "Rebases the current working tree on top of an existing remote branch (default development)."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g refresh $argv
end

function g_finish --description "Merges a branch back to its remote branch."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g finish $argv
end

function g_full_finish --description "Merges a branch back to its remote branch and then deletes the branch."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g full_finish $argv
end

function g_fast_commit --description "Creates a local branch, commit changes and then merges it back to the base branch."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g fast_commit $argv
end

function g_reset --description "Cleans up a local branch."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g reset $argv
end

function g_delete --description "Deletes a branch locally and remotely."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g delete $argv
end

function g_cleanup --description "Removes all merged branch."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g cleanup $argv
end

function g_release --description "Tags a release."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g release $argv
end

function g_start_from_release --description "Starts a fix on a release"
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g start_from_release $argv
end

function g_refresh_from_release --description "Rebases the current fix branch on top of the release."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g refresh_from_release $argv
end

function g_finish_to_release --description "Merges the current fix branch to the release."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g finish_to_release $argv
end

function g_full_finish_to_release --description "Merges the current fix branch to the release and then deletes the branch."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g full_finish_to_release $argv
end

function g_import --description "Imports latest changes from a branch on top of an existing remote branch (default development)."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g import $argv
end

function g_import_release --description "Imports a release."
  eval $FISHAMNIUM_NODE ~/.fishamnium/helpers/g import_release $argv
end
