# ----- Internal functions -----

function __g_status
	if test -n "$dryRun"
		printf "%s%s--> Would execute: %s%s%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_SECONDARY" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$argv" "$FISHAMNIUM_COLOR_RESET"
	else 
		printf "%s%s--> %s%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$argv" "$FISHAMNIUM_COLOR_RESET"
	end
end

function __git
	__g_status git $argv

	if test -z "$dryRun"
  	git $argv
	end
end

function __g_ensure_branch
	if test -n "$argv[1]"
    echo $argv[1]
  else
    g_default_branch
  end
end

function __g_ensure_remote
	if test -n "$argv[1]"
    echo $argv[1]
  else
    g_default_remote
  end
end

function __g_refresh
  set remote $argv[1]
  set base $argv[2]
  set branch $argv[3]
  set operation $argv[4]

  __git fetch $remote; or return
	__git checkout $base; or return
	__git pull $remote $base; or return
  __git checkout $branch; or return
  __git $operation $base; or return
end

function __g_pull_request_create_url
  set base $argv[1]
  set branch $argv[2]
  set escapedBase (string escape --style=url -- "$base")
  set escapedBranch (string escape --style=url -- "$branch")

  for remote in upstream origin
    set url $($FISHAMNIUM_HELPER git remote-url $remote 2>/dev/null); or continue

    set host
    set repo

    if string match -qr -- '^git@(?<host>github\.com|gitlab\.com):(?<repo>.+?)(?:\.git)?$' "$url"; or string match -qr -- '^https://(?<host>github\.com|gitlab\.com)/(?<repo>.+?)(?:\.git)?$' "$url"
      set repo (string replace -r '\.git$' '' -- "$repo")

      switch $host
        case github.com
          echo "https://github.com/$repo/pull/new/$escapedBranch"
          return 0
        case gitlab.com
          echo "https://gitlab.com/$repo/-/merge_requests/new?merge_request[source_branch]=$escapedBranch&merge_request[target_branch]=$escapedBase"
          return 0
      end
    end
  end

  return 1
end

function __g_pull_request
  set remote $argv[1]
  set base $argv[2]
  set branch $argv[3]

  if set -q _flag_f
    set pushOptions $pushOptions "-f"
  end

  if set -q _flag_s
    set pushOptions $pushOptions "--no-verify"
  end

  dryRun=$_flag_N __git push $pushOptions $remote $branch; or return
  set url $(__g_pull_request_create_url $base $branch)
  dryRun=$_flag_N __git checkout $base; or return
  dryRun=$_flag_N __git branch -D $branch  

  if test -n "$url"
    dryRun=$_flag_N __g_status /usr/bin/open "$url"

    if test -z "$_flag_N"
      /usr/bin/open "$url"
    end
  else
    printf "%s%s--> Cannot generate Pull Request URL from upstream or origin remotes.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_RESET"
  end
end



function __g_worktree_path_from_row
  set tab (printf "\t")
  set parts (string split -m 2 $tab "$argv[1]")
  set path (string replace -r '^~(?=/|$)' "$HOME" -- "$parts[2]")
  path normalize "$path"
end

# ----- Default functions -----

function g_default_branch -d "Get the default branch for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_DEFAULT_BRANCH"
		echo "$GIT_DEFAULT_BRANCH"
		return
	end

	# Lookup the value in the configuration file
	__fishamnium_get_configuration .git.branch
end

function g_default_remote -d "Get the default remote for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_DEFAULT_REMOTE"
		echo "$GIT_DEFAULT_REMOTE"
		return
	end

	# Lookup the value in the configuration file
  __fishamnium_get_configuration .git.remote
end

# ----- Reading functions -----
function g_is_repository -d "Check if the current directory is a GIT repository"
  if ! $FISHAMNIUM_HELPER git is-repository >/dev/null 2>/dev/null
    __fishamnium_print_error "You are not inside a git repository."
    return 1
  end
end

function g_is_dirty -d "Check if the current GIT repository has uncommitted changes"
  g_is_repository; or return

  set output $($FISHAMNIUM_HELPER git dirty 2>/dev/null)
  test -n "$output"
end

function g_summary -d "Get a summary of current GIT repository branch, SHA and dirty status"
  g_is_repository; or return

  set branch $(g_branch_name); or return
  set sha $(g_sha); or return
  echo $branch $sha $(g_is_dirty; and echo "true"; or echo "false")
end

function g_remotes -d "Show GIT remotes in JSON format"
  g_is_repository; or return

  $FISHAMNIUM_HELPER git remotes
end

function g_remotes_autocomplete -d "List remotes name and description for autocompletion"
  g_is_repository; or return

  $FISHAMNIUM_HELPER git remotes-autocomplete
end

function g_branch_name -d "Get the current branch name"
  g_is_repository; or return

  $FISHAMNIUM_HELPER git branch-name
end

function g_full_branch_name -d "Get the full current branch name"
  g_is_repository; or return

  $FISHAMNIUM_HELPER git full-branch-name
end

function g_sha -d "Get the current GIT SHA"
  g_is_repository; or return

  $FISHAMNIUM_HELPER git sha
end

function g_full_sha -d "Get the full current GIT SHA"
  g_is_repository; or return

  $FISHAMNIUM_HELPER git full-sha
end

function g_pull_request_url -d "Get a Pull Request URL"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_pull_request_url "r/remote=" -- $argv
  set base $(__g_ensure_branch $argv[1])
  set remote $(__g_ensure_remote $_flag_r)

  set branch $argv[2]
  if test -z $branch
    set branch $($FISHAMNIUM_HELPER git branch-name); or return
  end

  if test "$base" = "$branch"
    __fishamnium_print_error "You are already on the base branch."
    return 1
  end

  set repo
  if set url $($FISHAMNIUM_HELPER git remote-url $remote 2>/dev/null)
    if string match -qr -- '^git@github\.com:(?<repo>.+?)(?:\.git)?$' "$url"; or string match -qr -- '^https://github\.com/(?<repo>.+?)(?:\.git)?$' "$url"
      set repo (string replace -r '\.git$' '' -- "$repo")
    end
  end

  if test -n "$repo"
    gh pr view "$branch" --repo "$repo" --json url --jq .url 2>/dev/null; or begin
      __fishamnium_print_error "Cannot get Pull Request URL."
      return 1
    end

    return 0
  end

  gh pr view "$branch" --json url --jq .url 2>/dev/null; or begin
    __fishamnium_print_error "Cannot get Pull Request URL."
    return 1
  end
end

# ----- Writing functions -----

function g_push -d "Pushes the current or others branch to a remote"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_push "r/remote=" "N/dry-run" -- $argv
  set remote $(__g_ensure_remote $_flag_r) 

  # Check if we need to force the branch
  if ! string match -qr -- "(?:^|\\s)[^-]" "$argv"
    set argv $argv $($FISHAMNIUM_HELPER git branch-name); or return
  end

  # Execute command(s)
  dryRun=$_flag_N __git push $remote $argv
end

function g_update -d "Fetchs and pulls a branch from a remote"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_update "r/remote=" "N/dry-run" -- $argv
  set remote $(__g_ensure_remote $_flag_r)

  # Check if we need to force the branch
  if ! string match -qr -- "(?:^|\\s)[^-]" "$argv"
    set argv $argv $($FISHAMNIUM_HELPER git branch-name); or return
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
  set remote $(__g_ensure_remote $_flag_r)

  if test $(count $argv) -eq 0
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
  argparse -i --name=g_cleanup "f/force" "N/dry-run" -- $argv
  set base $(__g_ensure_branch $argv[1])

  # Prepare the branches to remove
  if set -q _flag_f
    set branches $(git branch --list | string match -r -- "^\s{2}(?!$base).+" | string trim); or return
  else
    set branches $(git branch --list --merged $base | string match -r -- "^\s{2}(?!$base).+" | string trim); or return
  end
  
  # Execute command(s)
  if test $(count $branches) -gt 0
    dryRun=$_flag_N __git branch -D $branches
  end
end

function g_switch -d "Interactively switch between local branch"
  g_is_repository; or return

  set branches $($FISHAMNIUM_HELPER git branches)

  set choice $(string join0 $branches | $FISHAMNIUM_HELPER select --prompt "Which branch you want to checkout")
  
  if test $status -eq 0
    __g_status "git checkout $choice"
    git checkout $choice
  end
end

function g_branch_delete_select -d "Interactively delete local branches"
  g_is_repository; or return

  set current $(g_branch_name); or return
  set current_pattern (string escape --style=regex -- $current)
  set branches $($FISHAMNIUM_HELPER git branches | string match -vr -- "^$current_pattern	")

  set choices $(string join0 $branches | $FISHAMNIUM_HELPER select --prompt "Which branches do you want to delete? (current branch is filtered out)" --multi)
  
  if test $status -eq 0
    __git branch -D $choices
  end
end

function g_worktree_cd_select -d "Interactively change current directory to a worktree"
  g_is_repository; or return

  if ! set choice $($FISHAMNIUM_HELPER git worktrees | $FISHAMNIUM_HELPER select --prompt "Which worktree do you want to move to" --raw)
    return 1
  end

  if test -z "$choice"
    return 1
  end

  set destination (__g_worktree_path_from_row "$choice")
  if test -z "$destination"
    __fishamnium_print_error "Worktree path not found."
    return 1
  end

  cd "$destination"
end

function g_worktree_delete_select -d "Interactively delete worktrees"
  g_is_repository; or return

  set current $(git rev-parse --show-toplevel); or return
  set worktrees $($FISHAMNIUM_HELPER git worktrees); or return

  for worktree in $worktrees
    set path (__g_worktree_path_from_row "$worktree")

    if test "$path" != "$current"
      set candidates $candidates "$worktree"
    end
  end

  if test $(count $candidates) -eq 0
    return 1
  end

  set choices $(string join0 $candidates | $FISHAMNIUM_HELPER select --prompt "Which worktrees do you want to delete? (current worktree is filtered out)" --multi --raw)

  if test $status -eq 0
    for choice in $choices
      set path (__g_worktree_path_from_row "$choice")
      set branch (git -C "$path" symbolic-ref --quiet --short HEAD)
      __git worktree remove "$path"; or return

      if test -n "$branch"
        __git branch -D -- "$branch"; or return
      end
    end
  end
end

# ----- Workflow functions -----

function g_start -d "Starts a new branch out of the base one"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_start "r/remote=" "N/dry-run" -- $argv
  set branch $argv[1]
  set base $(__g_ensure_branch $argv[2])
  set remote $(__g_ensure_remote $_flag_r)

  # Normalize remote
  if set -q _flag_r
    set remote $_flag_r
  else
    set remote $(g_default_remote)
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
  argparse -i --name=g_refresh "m/merge" "r/remote=" "N/dry-run" -- $argv
  set branch $(g_branch_name); or return
  set base $(__g_ensure_branch $argv[1])
  set remote $(__g_ensure_remote $_flag_r)
  set operation "rebase"

  if set -q _flag_m
    set operation "merge"
  end

  if test $base = $branch
    __fishamnium_print_error "You are already on the base branch. Use the g_update command."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __g_refresh $remote $base $branch $operation
end

function g_pull_request -d "Sends a Pull Request and deletes the local branch"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_pull_request "r/remote=" "N/dry-run" "f/force" "s/no-verify" -- $argv
  set branch $(g_branch_name); or return
  set base $(__g_ensure_branch $argv[1])
  set remote $(__g_ensure_remote $_flag_r)

  if test $base = $branch
    __fishamnium_print_error "You are already on the base branch."
    return 1
  end

  # Execute command(s)
  dryRun=$_flag_N __g_status g_refresh
  dryRun=$_flag_N __g_refresh $remote $base $branch rebase
  _flag_f=$_flag_f _flag_s=$_flag_s _flag_N=$_flag_N __g_pull_request $remote $base $branch
end

function g_fast_pull_request -d "Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_fast_pull_request "r/remote=" "N/dry-run" "f/force" "s/no-verify" -- $argv
  set branch $argv[1]
  set message $argv[2]
  set base $(__g_ensure_branch $argv[3])
  set remote $(__g_ensure_remote $_flag_r)

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
  dryRun=$_flag_N __git commit -s -a -m "$message"; or return
  dryRun=$_flag_N __g_status g_refresh
  dryRun=$_flag_N __g_refresh $remote $base $branch rebase
  dryRun=$_flag_N __g_status g_pull_request
  _flag_f=$_flag_f _flag_s=$_flag_s _flag_N=$_flag_N __g_pull_request $remote $base $branch
end

function g_sync -d "Syncs two remotes"
  g_is_repository; or return

  # Parse arguments
  argparse -i --name=g_sync "r/remote=" "u/upstream=" "N/dry-run" -- $argv
  
  set remote $(__g_ensure_remote $_flag_r)
  set branch $(__g_ensure_branch $argv[1])

  if test -z "$_flag_u"
    set upstream $(__fishamnium_get_configuration .git.upstreamRemote)
  else
    set upstream $_flag_u
  end

  dryRun=$_flag_N __git fetch $upstream; or return
  dryRun=$_flag_N __git pull $upstream $branch; or return
  dryRun=$_flag_N __git push -f $remote $branch; or return
end

# ----- GitHub functions -----
function gh_pr_branch -d "Shows the branch of a PR"
  g_is_repository; or return
  gh pr view $argv[1] --json headRefName --jq .headRefName
end 

function gh_pr_approve -d "Approves a PR"
  g_is_repository; or return

  set pr $argv[1]
  set message $argv[2]

  if test -z "$pr"
    __fishamnium_print_error "You must provide a PR ID."
    return 1
  else if test -z "$message"
    set message $(__fishamnium_get_configuration .git.approvalMessage)
  end

  gh pr review -a -b "$message" $pr
end

function gh_remote_add -d "Adds a remote for a PR"
  g_is_repository; or return

  set repository $argv[1]
  set name $argv[2]

  if test -z "$repository"
    __fishamnium_print_error "You must provide a repository in the form of owner/repo."
    return 1
  end
  
  if test -z "$name"
    set name $(g_default_remote)
  end

  git remote add $name git@github.com:$repository.git
end
