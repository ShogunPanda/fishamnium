# Remove existing completions
for i in g_commit_with_task g_commit_all_with_task g_push g_update g_reset g_delete g_cleanup
  complete -c $i -e
end

# Add common options
for i in g_commit_with_task g_commit_all_with_task g_push g_reset g_delete g_cleanup
  complete -c $i -s N -l dry-run -d "Do not execute operation, only print the commands"
end

for i in g_push g_update g_delete g_cleanup
  complete -c $i -s r -l remote -x -a "(__fishamnium_git_remotes)" -d "The remote to use"
end

# Other commands
complete -c g_reset -x -a ""

complete -c g_delete -x -a "(__fishamnium_git_branches)"

complete -c g_cleanup -x -a ""
complete -c g_cleanup -n "__fishamnium_is_git_argument 0" -x -a "(__fishamnium_git_branches)"

# g_push
complete -c g_push -x -a ""
complete -c g_push -n "__fishamnium_is_git_argument 0" -x -a "(__fishamnium_git_branches)"
# Keep in sync with the options for git push in https://github.com/fish-shell/fish-shell/blob/master/share/completions/git.fish
complete -c g_push -l all -d 'Push all refs under refs/heads/'
complete -c g_push -l prune -d "Remove remote branches that don't have a local counterpart"
complete -c g_push -l mirror -d 'Push all refs under refs/'
complete -c g_push -l delete -d 'Delete all listed refs from the remote repository'
complete -c g_push -l tags -d 'Push all refs under refs/tags'
complete -c g_push -l follow-tags -d 'Push all usual refs plus the ones under refs/tags'
complete -c g_push -s n -l dry-run -d 'Do everything except actually send the updates'
complete -c g_push -l porcelain -d 'Produce machine-readable output'
complete -c g_push -s f -l force -d 'Force update of remote refs'
complete -c g_push -s f -l force-with-lease -d 'Force update of remote refs, stopping if other\'s changes would be overwritten'
complete -c g_push -s u -l set-upstream -d 'Add upstream (tracking) reference'
complete -c g_push -s q -l quiet -d 'Be quiet'
complete -c g_push -s v -l verbose -d 'Be verbose'
complete -c g_push -l progress -d 'Force progress status'

# g_update
complete -c g_update -x -a ""
complete -c g_update -n "__fishamnium_is_git_argument 0" -x -a "(__fishamnium_git_branches)"
# Keep in sync with the options for git pull in https://github.com/fish-shell/fish-shell/blob/master/share/completions/git.fish
complete -c g_update -s q -l quiet -d 'Be quiet'
complete -c g_update -s v -l verbose -d 'Be verbose'
# Options related to fetching
complete -c g_update -l all -d 'Fetch all remotes'
complete -c g_update -s a -l append -d 'Append ref names and object names'
complete -c g_update -s f -l force -d 'Force update of local branches'
complete -c g_update -s k -l keep -d 'Keep downloaded pack'
complete -c g_update -l no-tags -d 'Disable automatic tag following'
complete -c g_update -s p -l prune -d 'Remove remote-tracking references that no longer exist on the remote'
# TODO --upload-pack
complete -c g_update -l progress -d 'Force progress status'
complete -f -c git -n '__fish_git_using_command pull; and not __fish_git_branch_for_remote' -a '(__fish_git_remotes)' -d 'Remote alias'
complete -f -c git -n '__fish_git_using_command pull; and __fish_git_branch_for_remote' -a '(__fish_git_branch_for_remote)'
# Options related to merging
complete -c g_update -l commit -d "Autocommit the merge"
complete -c g_update -l no-commit -d "Don't autocommit the merge"
complete -c g_update -s e -l edit -d 'Edit auto-generated merge message'
complete -c g_update -l no-edit -d "Don't edit auto-generated merge message"
complete -c g_update -l ff -d "Don't generate a merge commit if merge is fast-forward"
complete -c g_update -l no-ff -d "Generate a merge commit even if merge is fast-forward"
complete -c g_update -l ff-only -d 'Refuse to merge unless fast-forward possible'
complete -c g_update -s S -l gpg-sign -d 'GPG-sign the merge commit'
complete -c g_update -l log -d 'Populate the log message with one-line descriptions'
complete -c g_update -l no-log -d "Don't populate the log message with one-line descriptions"
complete -c g_update -l signoff -d 'Add Signed-off-by line at the end of the merge commit message'
complete -c g_update -l no-signoff -d 'Do not add a Signed-off-by line at the end of the merge commit message'
complete -c g_update -l stat -d "Show diffstat of the merge"
complete -c g_update -s n -l no-stat -d "Don't show diffstat of the merge"
complete -c g_update -l squash -d "Squash changes from upstream branch as a single commit"
complete -c g_update -l no-squash -d "Don't squash changes"
complete -c g_update -s s -l strategy -d 'Use the given merge strategy'
complete -c g_update -s X -l strategy-option -d 'Pass given option to the merge strategy'
complete -c g_update -l verify-signatures -d 'Abort merge if upstream branch tip commit is not signed with a valid key'
complete -c g_update -l no-verify-signatures -d 'Do not abort merge if upstream branch tip commit is not signed with a valid key'
complete -c g_update -l allow-unrelated-histories -d 'Allow merging even when branches do not share a common history'
complete -c g_update -s r -l rebase -d 'Rebase the current branch on top of the upstream branch'
complete -c g_update -l no-rebase -d 'Do not rebase the current branch on top of the upstream branch'
complete -c g_update -l autostash -d 'Before starting rebase, stash local changes, and apply stash when done'
complete -c g_update -l no-autostash -d 'Do not stash local changes before starting rebase'