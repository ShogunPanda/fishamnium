#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function g_default_branch --description "Fallbacks a remote to development."
  if test -n "$argv[1]"
    echo $argv[1]
  else if test -n "$GIT_DEFAULT_BRANCH"
    echo $GIT_DEFAULT_BRANCH
  else
    echo "development"
  end
end

function g_default_remote --description "Fallbacks a remote to origin."
  if test -n "$argv[1]"
    echo $argv[1]
  else if test -n "$GIT_DEFAULT_REMOTE"
    echo $GIT_DEFAULT_REMOTE
  else
    echo "origin"
  end
end

function g_start --description "Starts a new branch off a remote existing branch (default development)."
  echo $argv | read -l new base origin
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  git fetch;
  git checkout $base; and git pull $origin $base; and git checkout -b $new
end

function g_release --description "Tags a release."
  echo $argv | read -l new base origin
  set -l new "release-$new"
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  g_start $new $base $origin; and git push -f $origin $new
end

function g_refresh --description "Rebases the current working tree on top of an existing remote branch (default development)."
  echo $argv | read -l base origin
  set -l current (gbn)
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  git fetch;
  git checkout $base; and git pull $origin $base; and git checkout $current; and git rebase $base;
end

function g_finish --description "Merges a branch back to its remote branch."
  echo $argv | read -l base origin
  set -l current (gbn)
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  g_refresh $base $origin; and git checkout $base; and git merge --no-ff $current; and git push $origin $base;
end

function g_reset --description "Cleans up a local branch."
  git reset --hard; and git clean -f;
end

function g_delete --description "Deletes a branch locally and remotely."
  test (count $argv) -gt 1; and set -l branches $argv[1..-2]; or set -l branches $argv[1]
  test (count $argv) -gt 1; and set -l origin $argv[-1]; or set -l origin ""
  set -l origin (g_default_remote $origin)

  for branch in $branches
    git branch -D $branch; and git push $origin :$branch
  end
end

function g_cleanup --description "Removes all merged branch."
  set -l branches (git branch --merged | grep -v '^*' | sed 's#  ##' | grep -v -E '^(development|master)$')
  test -n "$branches"; and git branch -D $branches
end
