# Remove completions for internal commands
for i in fishamnium_reload __fishamnium_print_error __fishamnium_find_configuration_file __fishamnium_get_configuration
  complete -c $i -e
  complete -c $i -x -a ""
end

for i in __g_status __git __g_open __g_ensure_branch __g_ensure_remote g_default_branch g_default_remote g_task_matchers g_task_template g_open_path g_release_prefix
  complete -c $i -e
  complete -c $i -x -a ""
end

for i in __g_refresh __g_finish __g_pull_request
  complete -c $i -e
  complete -c $i -x -a ""
end