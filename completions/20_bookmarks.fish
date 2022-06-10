function __fishamnium_is_bookmark_argument
  status --is-interactive; or exit 1
  
  set index $argv[1]
  set cmd $(commandline -opc)
  set -e cmd[1]

  test $(count $argv) -eq $index
end

# Remove existing completions
for i in bookmarks_list bookmark_show bookmark_save bookmark_delete bookmark_cd bookmark_open bookmark_edit
  complete -c $i -e
end

# List and save don't take autocompletions
complete -c bookmarks_list -x -a ""
complete -c bookmark_save -x -a ""

# All other commands take only the bookmark name as completions
for i in bookmark_show bookmark_delete bookmark_cd bookmark_open bookmark_edit
  complete -c $i -x -n "test $(__fishamnium_is_bookmark_argument 1)" -a "(bookmarks_autocomplete)"
  complete -c $i -x -n "test $(__fishamnium_is_bookmark_argument 2)" -a ""
end