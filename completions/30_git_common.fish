function __fishamnium_is_git_argument
  status --is-interactive; or exit 1

  set index $argv[1]
  set cmd $(commandline -opc)
  set -e cmd[1]

  argparse -i "N/dry-run" "r/remote=" "f/force" "s/no-verify" "a/all" -- $cmd >/dev/null 2>/dev/null
  test $(count $argv) -eq $index
end

function __fishamnium_git_branches
  git for-each-ref --format='%(refname:strip=2)' refs/heads/ 2>/dev/null | string replace -rf '.*' '$0\tLocal Branch'
end

function __fishamnium_git_remotes
  git remote 2>/dev/null | string replace -rf '.*' '$0\tRemote'
end

# Remove completions for internal commands
complete -c __fishamnium_is_git_argument -e
complete -c __fishamnium_is_git_argument -x -a ""