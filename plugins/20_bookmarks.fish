function __bookmarks_list
  $FISHAMNIUM_HELPER bookmarks tsv $argv
end

function __bookmarks_get_path
  $FISHAMNIUM_HELPER bookmarks show $argv[1]  
end

function bookmarks_list -d "Lists all bookmarks"
  set query ".+"

  argparse -i --name=bookmarks_list "e/export" "p/export-prefix=" -- $argv

  if test -n "$argv[1]"
    set query "(?:$argv[1])"
  end

  if test -n "$_flag_e"
    set exportPrefix $_flag_p

    if test -z "$exportPrefix"
      set exportPrefix $(__fishamnium_get_configuration .bookmarksExportPrefix)
    end

    for line in $($FISHAMNIUM_HELPER bookmarks export "$query" "$exportPrefix")
      set parts (string split -m 1 -- "=" "$line")
      test (count $parts) -eq 2; or continue
      echo "set -x -g $parts[1] $parts[2]"
    end

    return
  end

  $FISHAMNIUM_HELPER bookmarks list "$query"
end

function bookmarks_autocomplete -d "Autocomplete bookmarks"
  $FISHAMNIUM_HELPER bookmarks autocomplete $argv
end

function bookmarks_names -d "Lists all bookmarks names"
  $FISHAMNIUM_HELPER bookmarks names $argv
end

function bookmark_show -d "Reads a bookmark"
  argparse -i --name=bookmark_show "y/copy" -- $argv

  set query $argv[1]

  if test -z "$query"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  if ! set destination $(__bookmarks_get_path $query)
    __fishamnium_print_error "The bookmark $FISHAMNIUM_COLOR_RESET$FISHAMNIUM_COLOR_BOLD$query$FISHAMNIUM_COLOR_ERROR$FISHAMNIUM_COLOR_NORMAL does not exists."
    return 1
  end

  if set -q _flag_y
    echo -n "$destination" | fish_clipboard_copy
  end

  echo "$destination"
end

function bookmark_save -d "Writes a bookmark"
  set bookmark $argv[1]
  set name $argv[2]

  if test -z "$bookmark"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  test -z "$name"; and set name $bookmark
  $FISHAMNIUM_HELPER bookmarks save "$bookmark" "$name"
end

function bookmark_delete -d "Deletes a bookmark"
  set bookmark $argv[1]

  if test -z "$bookmark"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  $FISHAMNIUM_HELPER bookmarks delete "$bookmark"
end

function bookmark_cd -d "Changes current directory to a saved bookmark"
  argparse -i --name=bookmark_cd "z/zoxide" -- $argv

  if ! set destination $(bookmark_show $argv 2>/dev/null)
    echo "$destination"
    return 1
  end

  if set -q _flag_z
    zoxide "$destination"
  else
    cd "$destination"
  end
end

function bookmark_open -d "Edits a bookmark using the current editor"
  if ! set destination $(bookmark_show $argv 2>/dev/null)
    echo "$destination"
    return 1
  end

  $GEDITOR "$destination"
end

function bookmark_edit -d "Edits a bookmark using the current terminal editor"
  if ! set destination $(bookmark_show $argv 2>/dev/null)
    echo $destination
    return 1
  end

  $EDITOR "$destination"
end

function bookmark_delete_select -d "Interactively deletes a bookmark"
  set bookmarks $(bookmarks_names)
  set prompt "--> Which bookmark you want to delete?"
  set colors $FISHAMNIUM_INTERACTIVE_COLORS
  set height $(math $(count $bookmarks) + 1)

  set choice $(string join0 $bookmarks | fzf --read0 -e --prompt "$prompt " --info=hidden --preview-window=hidden --height $height --reverse --color $colors)

  if test $status -eq 0
    bookmark_delete "$choice"
  end
end

function bookmark_cd_select -d "Interactively deletes a bookmark"
  argparse -i --name=bookmbookmark_cd_select "z/zoxide" -- $argv

  set bookmarks $(bookmarks_names)
  set prompt "--> Which bookmark you want to move to?"
  set colors $FISHAMNIUM_INTERACTIVE_COLORS
  set height $(math $(count $bookmarks) + 1)

  set choice $(string join0 $bookmarks | fzf --read0 -e --prompt "$prompt " --info=hidden --preview-window=hidden --height $height --reverse --color $colors)

  if test $status -eq 0
    if set -q _flag_z
      zoxide add -- "$choice"
    else
      cd "$choice"
    end
  end
end

function bookmark_open_select -d "Interactively edits a bookmark using the current editor"
  set bookmarks $(bookmarks_names)
  set prompt "--> Which bookmark you want to open?"
  set colors $FISHAMNIUM_INTERACTIVE_COLORS
  set height $(math $(count $bookmarks) + 1)

  set choice $(string join0 $bookmarks | fzf --read0 -e --prompt "$prompt " --info=hidden --preview-window=hidden --height $height --reverse --color $colors)

  if test $status -eq 0
    cd "$choice"
  end
end

function bookmarks_export_to_env -d "Exports bookmarks as environment variables"
  bookmarks_list -e > $FISHAMNIUM_ROOT/plugins/21_bookmarks.fish
  chmod a+x $FISHAMNIUM_ROOT/plugins/21_bookmarks.fish
  source $FISHAMNIUM_ROOT/plugins/21_bookmarks.fish
end

alias l=bookmarks_list
alias le=bookmarks_export_to_env
alias b=bookmark_show
alias y="bookmark_show -y"
alias s=bookmark_save
alias d=bookmark_delete
alias c=bookmark_cd
alias cz="bookmark_cd -z"
alias o=bookmark_open
alias e=bookmark_edit
alias ds=bookmark_delete_select
alias csz="bookmark_cd_select -z"
alias os=bookmark_open_select
