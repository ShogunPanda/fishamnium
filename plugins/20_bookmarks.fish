function bookmarks_list -d "Lists all bookmarks"
  set query ".+"

  argparse -i --name=bookmarks_list "e/export" "p/export-prefix=" -- $argv

  if test -n "$argv[1]"
    set query "(?:$argv[1])"
  end

  # Gather bookmarks
  for raw in $(yq -o=csv -eMP ".bookmarks | to_entries | map([.key, .value.path, .value.name])" $FISHAMNIUM_CONFIG | sort | string split -- "\n")
    set bookmark $(string split -- "," "$raw")

    if string match -qre "$query" "$bookmark[1]"
      set bookmarks $bookmarks $bookmark
    end
  end

  if test $(count $bookmarks) -eq 0
    return
  end

  set indexes $(seq 1 3 $(math $(count $bookmarks) - 1))

  # Shell export
  if test -n "$_flag_e"
    set exportPrefix $_flag_p

    if test -z $exportPrefix
      set exportPrefix "B_"
    end

    for i in $indexes
      set name $(string upper -- (string replace --all -- "-" "_" "$bookmarks[$i]"))
      set destination $(string replace -- "~" "$HOME" $bookmarks[(math $i + 1)])
      echo "set -x -g $exportPrefix$name \"$destination\""
    end

    return
  end

  # Calculate paddings
  set idPadding 0
  set destinationPadding 0
  set namePadding 0

  for i in $indexes
    set idPadding $(math max \($idPadding, $(string length $bookmarks[$i])\))
    set destinationPadding $(math max \($destinationPadding, $(string length $bookmarks[(math $i + 1)])\))
    set namePadding $(math max \($namePadding, $(string length $bookmarks[(math $i + 2)])\))
  end

  # Prepare the row - In the destination we use 6 as ~ will be replaced with ~
  set row $(printf "+%s+%s+%s+" $(string repeat -n $(math $idPadding + 2) '-') $(string repeat -n $(math $destinationPadding + 6) '-') $(string repeat -n $(math $namePadding + 2) '-'))

  # Print the header - In the destination we use 6 as ~ will be replaced with ~
  echo $row
  printf "| %s | %s | %s |\n" $(string pad -r -w $idPadding "ID") $(string pad -r -w $(math $destinationPadding + 4) "Destination") $(string pad -r -w $namePadding "Name")
  echo $row

  # Print the bookmarks
  for i in $indexes
    set bookmark $(string pad -r -w $idPadding $bookmarks[$i])
    set destination $(string pad -r -w $destinationPadding $bookmarks[(math $i + 1)])
    set destination $(string replace "~" "$FISHAMNIUM_COLOR_PRIMARY\$HOME$FISHAMNIUM_COLOR_RESET" "$destination")
    set name $(string pad -r -w $namePadding $bookmarks[(math $i + 2)])

    printf "| $FISHAMNIUM_COLOR_SUCCESS$FISHAMNIUM_COLOR_BOLD%s$FISHAMNIUM_COLOR_RESET | %b | $FISHAMNIUM_COLOR_SECONDARY%s$FISHAMNIUM_COLOR_RESET |\n" "$bookmark" "$destination" "$name"
  end

  echo $row
end

function bookmarks_autocomplete -d "Autocomplete bookmarks"
  yq -o=tsv -eMP ".bookmarks | to_entries | map([.key, .value.path | sub(\"~\", \"\$\$HOME\")])" $FISHAMNIUM_CONFIG
end

function bookmarks_names -d "Lists all bookmarks names"
  yq -eMP ".bookmarks | keys | .[]" $FISHAMNIUM_CONFIG 2>/dev/null
end

function bookmark_show -d "Reads a bookmark"
  argparse -i --name=bookmark_show "y/copy" -- $argv

  # Parse arguments
  set bookmark $argv[1]

  if test -z "$bookmark"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  # Search the bookmark
  set destination (yq -eMP ".bookmarks[\"$bookmark\"] | .path | sub(\"~\", \"$HOME\")" $FISHAMNIUM_CONFIG 2>/dev/null)

  if test $status -ne 0
    __fishamnium_print_error "The bookmark $FISHAMNIUM_COLOR_RESET$FISHAMNIUM_COLOR_BOLD$bookmark$FISHAMNIUM_COLOR_ERROR$FISHAMNIUM_COLOR_NORMAL does not exists."
    return 1
  end

  if set -q _flag_y
    echo -n "$destination" | fish_clipboard_copy
  end

  echo $destination
end

function bookmark_save -d "Writes a bookmark"
  # Parse arguments
  set bookmark $argv[1]
  set destination $PWD
  set name $argv[2]

  if test -z "$bookmark"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  # Normalize arguments
  test -z "$name"; and set name $bookmark
  set destination $(string replace "$HOME" "~" "$destination")

  # Validate the bookmark name and that is not already existing
  if ! string match -qre "^(?:[a-z0-9-_.:@]+)\$" "$bookmark"
    __fishamnium_print_error "Use only letters, numbers, and -, _, ., : and @ for the name."
    return
  end

  if set existing $(bookmark_show $bookmark 2>/dev/null)
    __fishamnium_print_error "The bookmark $FISHAMNIUM_COLOR_RESET$FISHAMNIUM_COLOR_BOLD$bookmark$FISHAMNIUM_COLOR_ERROR$FISHAMNIUM_COLOR_NORMAL already exists and points to $FISHAMNIUM_COLOR_RESET$FISHAMNIUM_COLOR_BOLD$existing$FISHAMNIUM_COLOR_ERROR$FISHAMNIUM_COLOR_NORMAL."
    return 1
  end

  # Save the element
  set newElement $(printf '[{"name": "%s", "bookmark": "%s", "rootPath": "%s", "paths": [], "group": ""}]' "$name" "$bookmark" "$destination")

  if ! yq -i -o yaml ".bookmarks[\"$bookmark\"] |= {\"path\": \"$destination\", \"name\": \"$name\"}" $FISHAMNIUM_CONFIG 2>/dev/null
    __fishamnium_print_error "Cannot save the bookmark."
    return 1
  end
end

function bookmark_delete -d "Deletes a bookmark"
  # Parse arguments
  set bookmark $argv[1]

  if test -z "$bookmark"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  # Validate the bookmark
  if ! bookmark_show $bookmark >/dev/null
    __fishamnium_print_error "The bookmark $FISHAMNIUM_COLOR_RESET$FISHAMNIUM_COLOR_BOLD$bookmark$FISHAMNIUM_COLOR_ERROR$FISHAMNIUM_COLOR_NORMAL does not exists."
    return 1
  end

  # Remove the bookmark from the file
  if ! yq -i -o yaml "del(.bookmarks[\"$bookmark\"])" $FISHAMNIUM_CONFIG 2>/dev/null
    __fishamnium_print_error "Cannot delete the bookmark."
    return 1
  end
end

function bookmark_cd -d "Changes current directory to a saved bookmark"
  argparse -i --name=bookmark_cd "z/zoxide" -- $argv

  if ! set destination $(bookmark_show $argv 2>/dev/null)
    echo $destination
    return 1
  end

  if set -q _flag_z
    zoxide $destination
  else
    bookmark_cd $destination
  end
end

function bookmark_open -d "Edits a bookmark using the current editor"
  if ! set destination $(bookmark_show $argv 2>/dev/null)
    echo $destination
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
    bookmarks $choice
  end
end

function bookmark_cd_select -d "Interactively deletes a bookmark"
  argparse -i --name=bookmbookmark_cd_selectark_cd "z/zoxide" -- $argv

  set bookmarks $(bookmarks_names)
  set prompt "--> Which bookmark you want to move to?"
  set colors $FISHAMNIUM_INTERACTIVE_COLORS
  set height $(math $(count $bookmarks) + 1)

  set choice $(string join0 $bookmarks | fzf --read0 -e --prompt "$prompt " --info=hidden --preview-window=hidden --height $height --reverse --color $colors)

  if test $status -eq 0
    if set -q _flag_z
      zoxide add -- $choice
    else
      bookmark_cd $choice
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
    bookmark_cd $choice
  end
end

alias l=bookmarks_list
alias le="bookmarks_list -e > ~/.config/fishamnium/20_bookmarks.fish && chmod a+x ~/.config/fishamnium/20_bookmarks.fish"
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
