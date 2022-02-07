function __g_refresh
  set remote $argv[1]
  set base $argv[2]
  set branch $argv[3]

  __git fetch $remote; or return
	__git checkout $base; or return
	__git pull $remote $base; or return
  __git checkout $branch; or return
  __git rebase $base; or return
end

function __g_finish
  set remote $argv[1]
  set base $argv[2]
  set branch $argv[3]

  __g_refresh $remote $base $branch; or return
  __git checkout $base; or return
  __git merge --no-ff --no-edit $branch; or return
end

function __g_pull_request
  set remote $argv[1]
  set base $argv[2]
  set branch $argv[3]

  set url (g_pull_request_url -r $remote $base $branch); or return

  if set -q _flag_f
    set pushOptions $pushOptions "-f"
  end

  if set -q _flag_s
    set pushOptions $pushOptions "--no-verify"
  end

  dryRun=$_flag_N __git push $pushOptions $remote $branch; or return
  dryRun=$_flag_N __git checkout $base; or return
  dryRun=$_flag_N __git branch -D $branch  
  dryRun=$_flag_N __g_open "$url"
end

function g_start -d "Starts a new branch out of the base one"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_start "r/remote=" "N/dry-run" -- $argv
  set branch $argv[1]
  set base (__g_ensure_branch $argv[2])
  set remote (__g_ensure_remote $_flag_r)

  # Normalize remote
  if set -q _flag_r
    set remote $_flag_r
  else
    set remote (g_default_remote)
  end

  if test -z "$branch"
    __fishamnium_print_error "You must provide a branch name."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __git fetch $remote; or return
	dryRun=$_flag_N __git checkout $base; or return
	dryRun=$_flag_N __git pull $remote $base	; or return
  dryRun=$_flag_N __git checkout -b $branch; or return
end

function g_refresh -d "Rebases the current branch on top of an existing remote branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_refresh "r/remote=" "N/dry-run" -- $argv
  set branch (g_branch_name); or return
  set base (__g_ensure_branch $argv[1])
  set remote (__g_ensure_remote $_flag_r)

  if test $base = $branch
    __fishamnium_print_error "You are already on the base branch. Use the g_update command."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __g_refresh $remote $base $branch
end

function g_finish -d "Merges a branch back to its base remote branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_finish "r/remote=" "N/dry-run" -- $argv
  set branch (g_branch_name); or return
  set base (__g_ensure_branch $argv[1])
  set remote (__g_ensure_remote $_flag_r)

  if test "$base" = "$branch"
    __fishamnium_print_error "You are already on the base branch."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __g_finish $remote $base $branch
end

function g_full_finish -d "Merges a branch back to its base remote branch and then deletes the local copy"
  set branch (g_branch_name); or return
  g_finish $argv; or return

  # Parse arguments
  argparse -i --name=g_full_finish "N/dry-run" -- $argv

  # Execute command(s)
  dryRun=$_flag_N __g_status g_restore
  dryRun=$_flag_N __git branch -D $branch
end

function g_fast_commit -d "Creates a local branch, commit changes and then merges it back to the base branch"
  g_is_repository; or return
  
  # Parse arguments
  argparse -i --name=g_fast_commit "r/remote=" "N/dry-run" -- $argv
  set branch $argv[1]
  set message $argv[2]
  set base (__g_ensure_branch $argv[3])
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$branch"
    __fishamnium_print_error "You must provide a branch name."
    return 1
  else if test -z "$message"
    __fishamnium_print_error "You must provide a message."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __g_status g_start
  _flag_N=$_flag_N g_start -r $remote $branch $base; or return
  dryRun=$_flag_N __g_status g_commit_with_task
  _flag_N=$_flag_N g_commit_with_task $message; or return
  dryRun=$_flag_N __g_status g_finish
  dryRun=$_flag_N __g_finish $remote $base $branch; or return
  dryRun=$_flag_N __g_status g_restore
  dryRun=$_flag_N __git branch -D $branch
end

function g_pull_request -d "Sends a Pull Request and deletes the local branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_pull_request "r/remote=" "N/dry-run" "f/force" "s/no-verify" -- $argv
  set branch (g_branch_name); or return
  set base (__g_ensure_branch $argv[1])
  set remote (__g_ensure_remote $_flag_r)

  # Execute command(s)
  dryRun=$_flag_N __g_status g_refresh
  dryRun=$_flag_N __g_refresh $remote $base $branch
  _flag_f=$_flag_f _flag_s=$_flag_s _flag_N=$_flag_N __g_pull_request $remote $base $branch
end

function g_fast_pull_request -d "Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_fast_pull_request "r/remote=" "N/dry-run" "f/force" "s/no-verify" -- $argv
  set branch $argv[1]
  set message $argv[2]
  set base (__g_ensure_branch $argv[3])
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$branch"
    __fishamnium_print_error "You must provide a branch name."
    return 1
  else if test -z "$message"
    __fishamnium_print_error "You must provide a message."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __g_status g_start
  _flag_N=$_flag_N g_start -r $remote $branch $base; or return
  dryRun=$_flag_N __g_status g_commit_with_task
  _flag_N=$_flag_N g_commit_with_task $message; or return
  dryRun=$_flag_N __g_status g_refresh
  dryRun=$_flag_N __g_refresh $remote $base $branch
  dryRun=$_flag_N __g_status g_pull_request
  _flag_f=$_flag_f _flag_s=$_flag_s _flag_N=$_flag_N __g_pull_request $remote $base $branch
end

function g_release -d "Creates and pushes a new release branch out of the base one"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_release "r/remote=" "N/dry-run" "f/force" "s/no-verify" -- $argv
  set current (g_branch_name); or return
  set release $argv[1]
  set base (__g_ensure_branch $argv[2])
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$release"
    __fishamnium_print_error "You must provide a release version."
    return 1
  end

  set release (printf "%s%s" (g_release_prefix) "$release")

  if set -q _flag_f
    set pushOptions $pushOptions "-f"
  end

  if set -q _flag_s
    set pushOptions $pushOptions "--no-verify"
  end

  # Execute command(s)
  dryRun=$_flag_N __g_status g_start
  _flag_N=$_flag_N g_start -r $remote $release $base; or return
  dryRun=$_flag_N __g_status g_push
  dryRun=$_flag_N __git push $pushOptions $remote $release; or return
  dryRun=$_flag_N __g_status g_restore
  dryRun=$_flag_N __git checkout $current; or return
  dryRun=$_flag_N __git branch -D $release
end

function g_import -d "Imports latest changes to a local branch on top of an existing remote branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_import "r/remote=" "N/dry-run" -- $argv
  set base $argv[1]
  set destination $argv[2]
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$base"
    __fishamnium_print_error "You must provide a base (source) branch."
    return 1
  end

  if test -z "$destination"
    set destination (g_branch_name); or return
  end

  set temporary (printf "temporary-%d" (random))

  # Execute command(s)
  dryRun=$_flag_N __git branch -D $temporary 2>/dev/null
  dryRun=$_flag_N __g_status g_start
  _flag_N=$_flag_N g_start -r $remote $temporary $base; or return
  dryRun=$_flag_N __g_status g_finish
  dryRun=$_flag_N __g_finish $remote $destination $temporary; or return
  dryRun=$_flag_N __git branch -D $temporary 2>/dev/null
end

function g_start_release -d "Starts a new branch out of a remote release branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_start_release "r/remote=" "N/dry-run" -- $argv
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$argv[1]"
    __fishamnium_print_error "You must provide a release version."
    return 1
  else
    set argv[1] (printf "%s%s" (g_release_prefix) "$argv[1]")
  end

  _flag_N=$_flag_N _flag_r=$_flag_r g_start $argv
end

function g_refresh_release -d "Rebases the current branch on top of an existing remote release branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_refresh_release "r/remote=" "N/dry-run" -- $argv
  set branch (g_branch_name); or return
  set release $argv[1]
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$release"
    __fishamnium_print_error "You must provide a release version."
    return 1
  end

  set release (printf "%s%s" (g_release_prefix) "$release")

  # Execute command(s)
  dryRun=$_flag_N __g_refresh $remote $release $branch
end

function g_finish_release -d "Merges the current branch back to its base remote release branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_finish_release "r/remote=" "N/dry-run" -- $argv
  set branch (g_branch_name); or return
  set release $argv[1]
  set remote (__g_ensure_remote $_flag_r)

  if test -z "$release"
    __fishamnium_print_error "You must provide a release version."
    return 1
  end

  set release (printf "%s%s" (g_release_prefix) "$release")

  # Execute command(s)
  dryRun=$_flag_N __g_finish $remote $release $branch
end

function g_full_finish_release -d "Merges the current branch back to its base remote release branch and then deletes the local copy"
  set branch (g_branch_name); or return

  g_finish_release $argv; or return

  # Parse arguments
  argparse -i --name=g_full_finish_release "N/dry-run" -- $argv

  # Execute command(s)
  dryRun=$_flag_N __g_status g_restore
  dryRun=$_flag_N __git branch -D $branch
end

function g_import_release -d "Imports latest changes to a local branch on top of an existing remote release branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_import_release "r/remote=" "N/dry-run" -- $argv

  if test -z "$argv[1]"
    __fishamnium_print_error "You must provide a release version."
    return 1
  else
    set argv[1] (printf "%s%s" (g_release_prefix) "$argv[1]")
  end
  
  # Execute command(s)
  _flag_N=$_flag_N g_import $argv
end

function g_delete_release -d "Deletes a release branch locally and remotely"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_delete_release "r/remote=" "N/dry-run" -- $argv
  set remote (__g_ensure_remote $_flag_r)
  set prefix (g_release_prefix)

  if test (count $argv) -eq 0
    __fishamnium_print_error "You must provide at least a release version."
    return 1
  end

  # Prepare versions
  for arg in $argv
    set localBranches $localBranches (printf "%s%s" "$prefix" "$arg")
    set remoteBranches $remoteBranches (printf ":%s%s" "$prefix" "$arg")
  end

  # Execute command(s)
  dryRun=$_flag_N __git branch -D $localBranches; or return
  dryRun=$_flag_N __git push $remote $remoteBranches; or return
end
