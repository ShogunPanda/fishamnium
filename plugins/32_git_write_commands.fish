function g_commit_with_task --wraps "git commit" -d "Commit changes including the task name"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_commit_with_task "a/all" "N/dry-run" -- $argv
  set task (g_task)
  set message "$argv[1]"

  # Replace the message
  if test -z "$message"
    __fishamnium_print_error "You must provide a message."
    return 1
  end

  if test -n "$task"
    set message (string replace -- "@message@" "$message" (g_task_template))
    set message (string replace -- "@task@" "$task" "$message")
  end

  set -e argv[1]

  # Execute command(s)
  if set -q _flag_a
    dryRun=$_flag_N __git add -A; or return
  end

  dryRun=$_flag_N __git commit -m "$message" $argv
end

function g_commit_all_with_task --wraps "git commit" -d "Commit all changes including the task name"
  g_commit_with_task -a $argv
end

function g_push -d "Pushes the current or others branch to a remote"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_push "r/remote=" "N/dry-run" -- $argv
  set remote (__g_ensure_remote $_flag_r) 

  # Check if we need to force the branch
  if ! string match -qr -- "(?:^|\\s)[^-]" "$argv"
    set argv $argv (git branch --show-current 2>/dev/null); or return
  end

  # Execute command(s)
  dryRun=$_flag_N __git push $remote $argv
end

function g_update -d "Fetchs and pulls a branch from a remote"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_update "r/remote=" "N/dry-run" -- $argv
  set remote (__g_ensure_remote $_flag_r)

  # Check if we need to force the branch
  if ! string match -qr -- "(?:^|\\s)[^-]" "$argv"
    set argv $argv (git branch --show-current 2>/dev/null); or return
  end

  # Execute command(s)
  dryRun=$_flag_N __git fetch $remote; or return
  dryRun=$_flag_N __git pull $remote $argv; or return
end

function g_reset -d "Reset all uncommitted changes"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_reset "N/dry-run" -- $argv

  # Execute command(s)
  dryRun=$_flag_N __git reset --hard; or return
  dryRun=$_flag_N __git clean -f; or return
end

function g_delete -d "Deletes one or more branch both locally and on a remote"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_delete "r/remote=" "N/dry-run" -- $argv
  set remote (__g_ensure_remote $_flag_r)

  if test (count $argv) -eq 0
    __fishamnium_print_error "You must provide at least a branch."
    return 1
  end

  # Prepare the branches to remove
  for i in $argv
    set remoteBranches $remoteBranches :$i
  end

  # Execute command(s)
  dryRun=$_flag_N __git branch -D $argv; or return
  dryRun=$_flag_N __git push $remote $remoteBranches; or return
end

function g_cleanup -d "Deletes all non default branches"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_cleanup "N/dry-run" -- $argv
  set base (__g_ensure_branch $argv[1])
  set remote (__g_ensure_remote $_flag_r)

  # Prepare the branches to remove
  set branches (git branch --merged $base | string match -r -- "^\s{2}(?!$base).+" "$branches" | string trim); or return
  
  # Execute command(s)
  if test (count $branches) -gt 0
    dryRun=$_flag_N __git branch -D $branches
  end
end
