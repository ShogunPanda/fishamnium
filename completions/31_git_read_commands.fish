for i in g_is_repository g_is_dirty g_summary g_remotes g_remotes_autocomplete g_branch_name g_full_branch_name g_sha g_full_sha g_task g_pull_request_url
  # Remove existing completions
  complete -c $i -e
end

# Most commands don't take any arguments
for i in g_is_repository g_is_dirty g_summary g_remotes g_remotes_autocomplete g_branch_name g_full_branch_name g_sha g_full_sha g_task
  complete -c $i -e
  complete -c $i -x -a ""
end

# g_pull_request_url -r $remote $base $branch
complete -c g_pull_request_url -e
complete -c g_pull_request_url -s r -l remote -x -a "(__fishamnium_git_remotes)" -d "The remote to use"
complete -c g_pull_request_url -x -a ""
complete -c g_pull_request_url -n "__fishamnium_is_git_argument 0" -x -a "(__fishamnium_git_branches)"
complete -c g_pull_request_url -n "__fishamnium_is_git_argument 1" -x -a "(__fishamnium_git_branches)"