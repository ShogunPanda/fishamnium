#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function g_is_repository --wraps git --description "Check if the current directory is a GIT repository"
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
    __fishamnium_print_error "You are not inside a git repository."
    return 1
  end
end

function g_is_dirty --wraps git --description "Check if the current GIT repository has uncommitted changes"
  g_is_repository; or return

  set output (git status -s 2>/dev/null)
  test -n "$output"
end

function g_summary --wraps git --description "Get a summary of current GIT repository branch, SHA and dirty status"
  g_is_repository; or return

  set branch (g_branch_name); or return
  set sha (g_sha); or return
  echo $branch $sha (g_is_dirty; and echo "true"; or echo "false")
end

function g_remotes --wraps git --description "Show GIT remotes in JSON format"
  g_is_repository; or return

  # Prepare the remotes as JSON
  set remotes (git remote -v); or return
  for line in $remotes
    string match -qr -- "(?<name>\\S+)\\s+(?<url>\\S+)\\s+\\((?<type>fetch|push)\\)" -- "$line"
    set output $output (printf '{"remote":"%s","type":"%s","url":"%s"}' "$name" "$type" "$url")
  end

  # Format arguments
  # TODO@PI: You don't need printf
  printf "[%s]" (string join -- "," "$output") | yq -o json -MP '.[] as $item ireduce ({}; .[$item.remote][$item.type]=$item.url) | (.[] | select(.fetch == .push)) |= .fetch'
end

function g_remotes_autocomplete --wraps git --description "List remotes name and description for autocompletion"
  g_is_repository; or return

  set remotes (git remote -v | string match -e -- fetch); or return
  for line in $remotes
    string match -qr -- "(?<name>\\S+)\\s+(?<url>\\S+)" "$line"
    printf "%s\tGIT Remote: %s\n" "$name" "$url"
  end
end

function g_branch_name --wraps git --description "Get the current branch name"
  g_is_repository; or return

  git symbolic-ref --short HEAD
end

function g_full_branch_name --wraps git --description "Get the full current branch name"
  g_is_repository; or return

  git symbolic-ref HEAD
end

function g_sha --wraps git --description "Get the current GIT SHA"
  g_is_repository; or return

  git rev-parse --short HEAD
end

function g_full_sha --wraps git --description "Get the full current GIT SHA"
  g_is_repository; or return

  git rev-parse HEAD
end

function g_task --wraps git --description "Get the current task name from the branch name"
  g_is_repository; or return

  set branch (git symbolic-ref --short HEAD); or return
  set matchers '$GIT_TASK_MATCHERS ^(?<task>[a-z0-9]*-?\\d+)-{1,2} -{1,2}(?<task>[a-z0-9]*-?\\d+)$'
  for matcher in (string split -- " " (string trim -- "$matchers"))
    if string match -qir -- "$matcher" "$branch"
      echo $task
      return 0
    end
  end

  return 1
end

function g_pull_request_url --wraps git --description "Get a Pull Request URL"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_pull_request_url "r/remote=" -- $argv
  set base (__g_ensure_branch $argv[1])
  set remote (__g_ensure_remote $_flag_r)

  set branch $argv[2]
  if test -z $branch
    set branch (git symbolic-ref --short HEAD); or return
  end

  if test "$base" = "$branch"
    __fishamnium_print_error "You are already on the base branch."
    return 1
  end

  # Get the remote
  if ! set url (git remote get-url $remote 2>/dev/null)
    __fishamnium_print_error "Cannot get remote URL."
    return 1
  end
  
  # Parse the remote - Only GitHub and GitLab are supported out of the box, rest is left to the user
  set matchers (g_task_matchers)

  for matcher in (string split "\n" -- (string trim -- "$matchers"))
    # Split the matcher into parts
    string match -qr -- "(?<matcher>.+)\\s+(?<template>.+)" (string trim -- "$matcher"); or continue

    # Match agains the URL
    string match -qr -- "$matcher" "$url"; or continue

    set pr (string replace -- "@base@" "$base" "$template")
    set pr (string replace -- "@branch@" "$branch" "$pr")
    set pr (string replace -- "@repo@" "$repo" "$pr")

    echo $pr
    return 0
  end

  __fishamnium_print_error "Cannot get Pull Request URL."
  return 1
end
