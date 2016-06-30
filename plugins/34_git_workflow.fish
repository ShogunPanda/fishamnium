#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __g_default_base_help
  set -l name (test (count $argv) -gt 0; and echo $argv[1]; or echo "BASE");
  echo "Default $name is the value of \$GIT_DEFAULT_BRANCH variable or \"development\"."
end

function __g_default_origin_help
  set -l name (test (count $argv) -gt 0; and echo $argv[1]; or echo "ORIGIN");
  echo "Default $name is the value of \$GIT_DEFAULT_REMOTE variable or \"origin\"."
end

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
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_start NAME [BASE] [ORIGIN]"
    __g_default_base_help
    __g_default_origin_help
    return
  end

  echo $argv | read -l new base origin
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  git fetch
  git checkout $base; and git pull $origin $base; and git checkout -b $new
end

function g_refresh --description "Rebases the current working tree on top of an existing remote branch (default development)."
  if test "$argv[1]" = "-h"
    echo "Usage: g_release [BASE] [ORIGIN]"
    __g_default_base_help
    __g_default_origin_help
    return 1
  end

  echo $argv | read -l base origin
  set -l current (gbn)
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  git fetch
  git checkout $base; and git pull $origin $base; and git checkout $current; and git rebase $base
end

function g_finish --description "Merges a branch back to its remote branch."
  if test "$argv[1]" = "-h"
    echo "Usage: g_finish [BASE] [ORIGIN]"
    __g_default_base_help
    __g_default_origin_help
    return 1
  end

  echo $argv | read -l base origin
  set -l current (gbn)
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  g_refresh $base $origin; and git checkout $base; and git merge --no-ff $current; and git push $origin $base
end

function g_full_finish --description "Merges a branch back to its remote branch and then deletes the branch."
  if test "$argv[1]" = "-h"
    echo "Usage: g_full_finish [BASE] [ORIGIN]"
    __g_default_base_help
    __g_default_origin_help
    return 1
  end

  set -l current (gbn)
  g_finish $argv; and gbd $current
end

function g_fast_commit --description "Creates a local branch, commit changes and then merges it back to the base branch."
  if begin test (count $argv) -lt 2; or test "$argv[1]" = "-h"; end
    echo "Usage: g_fast_commit [BRANCH] [MESSAGE] [BASE]"
    __g_default_base_help
    return 1
  end

  echo $argv | read -l branch message base
  set -l base (g_default_branch $base)

  g_start $branch $base; and gca $message; and g_full_finish $base;
end

function g_reset --description "Cleans up a local branch."
  git reset --hard; and git clean -f
end

function g_delete --description "Deletes a branch locally and remotely."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_delete BRANCH... [ORIGIN]"
    __g_default_origin_help
    echo "When more than branch is given, ORIGIN is mandatory."
    return 1
  end

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

function g_release_tag --description "Tags a release."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_release_tag VERSION [BASE] [ORIGIN]"
    __g_default_base_help
    __g_default_origin_help
    echo "The final branch will be release-VERSION."
    return 1
  end

  echo $argv | read -l release base origin
  set -l release "release-$release"
  set -l base (g_default_branch $base)
  set -l origin (g_default_remote $origin)

  g_start $release $base $origin; and git push -f $origin $release
end

function g_release_start --description "Starts a fix on a release"
  set -l want_helps (test (count $argv) -gt 0; and test "$argv[1]" = "-h")

  if begin test $want_helps; or test (count $argv) -lt 2; end
    echo "Usage: g_release_start VERSION BRANCH [ORIGIN]"
    __g_default_origin_help
    echo "The final release branch will be release-VERSION."
    return 1
  end

  echo $argv | read -l release new origin
  g_start $new "release-$release" $origin
end

function g_release_refresh --description "Rebases the current fix branch on top of the release."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_release_refresh VERSION [ORIGIN]"
    __g_default_origin_help
    echo "The final release branch will be release-VERSION."
    return 1
  end

  echo $argv | read -l release origin
  g_refresh "release-$release" $origin
end

function g_release_finish --description "Merges the current fix branch to the release."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_release_finish VERSION [ORIGIN]"
    __g_default_origin_help
    echo "The final release branch will be release-VERSION."
    return 1
  end

  echo $argv | read -l release origin
  g_finish "release-$release" $origin
end

function g_release_full_finish --description "Merges the current fix branch to the release and then deletes the branch."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_release_full_finish VERSION [ORIGIN]"
    __g_default_origin_help
    echo "The final release branch will be release-VERSION."
    return 1
  end

  echo $argv | read -l release origin
  g_full_finish "release-$release" $origin
end

function g_import --description "Imports latest changes from a branch on top of an existing remote branch (default development)."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_import TEMPORARY [DESTINATION] [BASE] [ORIGIN]"
    echo "Default TEMPORARY is \"import-BASE\"."
    __g_default_base_help "DESTINATION"
    echo "Default BASE is \"development\"."
    __g_default_origin_help
    return 1
  end

  echo $argv | read -l temporary destination base origin
  set -l destination (g_default_branch $destination)
  test -z "$base"; and set -l base "development"
  test -z "$temporary"; and set -l temporary "import-$base"

  gbd $temporary
  g_start $temporary $base $origin; and g_refresh $destination $origin; and g_finish $destination $origin; and gbd $temporary
end

function g_import_release --description "Imports a release into production."
  if begin test (count $argv) -eq 0; or test "$argv[1]" = "-h"; end
    echo "Usage: g_import_release RELEASE [DESTINATION] [ORIGIN]"
    echo "The final release branch will be release-VERSION."
    echo "Default DESTINATIOn is \"development\"."
    __g_default_origin_help
    return 1
  end

  echo $argv | read -l release destination origin
  test -z "$destination"; and set -l base "development"
  g_import "import-release-$release" $destination "release-$release" $origin
end
