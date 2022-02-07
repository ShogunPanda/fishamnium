# Remove existing completions
for i in g_start g_refresh g_finish g_full_finish g_fast_commit g_pull_request g_fast_pull_request g_release g_import g_start_release g_refresh_release g_finish_release g_full_finish_release g_import_release g_delete_release
  complete -c $i -e
end

# Add common options
for i in g_start g_refresh g_finish g_full_finish g_fast_commit g_pull_request g_fast_pull_request g_release g_import g_start_release g_refresh_release g_finish_release g_full_finish_release g_import_release
  complete -c $i -x -a ""
end

for i in g_start g_refresh g_finish g_full_finish g_fast_commit g_pull_request g_fast_pull_request g_release g_import g_start_release g_refresh_release g_finish_release g_full_finish_release g_import_release g_delete_release
  complete -c $i -s N -l dry-run -d "Do not execute operation, only print the commands"
  complete -c $i -s r -l remote -x -a "(__fishamnium_git_remotes)" -d "The remote to use"
end

for i in g_pull_request g_fast_pull_request g_release
  complete -c $i -s f -l force -d "Use force push"
  complete -c $i -s s -l no-verify -d "Do not execute pre-push script"
end

# Complete various commands
for i in g_start g_start_release
  complete -c $i -x -n "__fishamnium_is_git_argument 1" -a "(__fishamnium_git_branches)"
end

for i in g_refresh g_finish g_full_finish g_refresh_release g_finish_release g_full_finish_release
  complete -c $i -x -n "__fishamnium_is_git_argument 0" -a "(__fishamnium_git_branches)"
end

complete -c g_fast_commit -x -n "__fishamnium_is_git_argument 2" -a "(__fishamnium_git_branches)"

complete -c g_pull_request -x -n "__fishamnium_is_git_argument 0" -a "(__fishamnium_git_branches)"

complete -c g_fast_pull_request -x -n "__fishamnium_is_git_argument 2" -a "(__fishamnium_git_branches)"

complete -c g_release -x -n "__fishamnium_is_git_argument 1" -a "(__fishamnium_git_branches)"

complete -c g_import -x -n "__fishamnium_is_git_argument 0" -a "(__fishamnium_git_branches)"
complete -c g_import_release -x -n "__fishamnium_is_git_argument 0" -a "(__fishamnium_git_branches)"

complete -c g_delete_release -x -a "(__fishamnium_git_branches)"