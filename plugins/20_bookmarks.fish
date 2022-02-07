function bookmarks_list -d "Lists all bookmarks"
  set query ".+"

  if test -n "$argv[1]"
    set query "^(?:$argv[1])"
  end

  # Gather bookmarks
  for raw in (yq -o=csv -eMP "to_entries | map([.value.bookmark, .value.rootPath | sub(\"\\\$home\", \"\$\$HOME\"), .value.name])" ~/.fishamnium_bookmarks.json | string split -- "\n")
    set bookmark (string split -- "," "$raw")

    if string match -qre "$query" "$bookmark[1]"
      set bookmarks $bookmarks $bookmark
    end
  end

  set indexes (seq 1 3 (math (count $bookmarks) - 1))

  # Calculate paddings
  set idPadding 0
  set destinationPadding 0
  set namePadding 0

  for i in $indexes
    set idPadding (math max \($idPadding, (string length $bookmarks[$i])\))    
    set destinationPadding (math max \($destinationPadding, (string length $bookmarks[(math $i + 1)])\))    
    set namePadding (math max \($namePadding, (string length $bookmarks[(math $i + 2)])\))    
  end

  # Prepare the row
  set row (printf "+%s+%s+%s+" (string repeat -n (math $idPadding + 2) '-') (string repeat -n (math $destinationPadding + 2) '-') (string repeat -n (math $namePadding + 2) '-'))

  # Print the header
  echo $row
  printf "| %s | %s | %s |\n" (string pad -r -w $idPadding "ID") (string pad -r -w $destinationPadding "Destination") (string pad -r -w $namePadding "Name")
  echo $row

  # Print the bookmarks
  for i in $indexes
    set bookmark (string pad -r -w $idPadding $bookmarks[$i])
    set destination (string pad -r -w $destinationPadding $bookmarks[(math $i + 1)])
    set destination (string replace "\$HOME" "\\x1b[33m\$HOME\x1b[0m" "$destination")
    set name (string pad -r -w $namePadding $bookmarks[(math $i + 2)])

    printf "| \x1b[32m\x1b[1m%s\x1b[0m | %b | \x1b[34m%s\x1b[0m |\n" "$bookmark" "$destination" "$name"
  end

  echo $row
end

function bookmarks_autocomplete -d "Autocomplete bookmarks"
  yq -o=tsv -eMP "to_entries | map([.value.bookmark, .value.rootPath | sub(\"\\\$home\", \"\$\$HOME\")])" ~/.fishamnium_bookmarks.json
end

function bookmarks_names -d "Lists all bookmarks names"
  yq -eMP ".[].bookmark"  ~/.fishamnium_bookmarks.json 2>/dev/null
end

function bookmark_show -d "Reads a bookmark"
  # Parse arguments
  set bookmark $argv[1]

  if test -z "$bookmark"
    __fishamnium_print_error "Please provide a bookmark name."
    return 1
  end

  # Search the bookmark
  if ! yq -eMP ".[] | select(.bookmark == \"$bookmark\") | .rootPath | . |= sub(\"\\\$home\", \"$HOME\")" ~/.fishamnium_bookmarks.json 2>/dev/null
    __fishamnium_print_error "The bookmark \x1b[0m\x1b[1m$bookmark\x1b[31m\x1b[22m does not exists."
    return 1
  end
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
  set destination (string replace "$HOME" "\$home" "$destination")

  # Validate the bookmark name and that is not already existing
  if ! string match -qre "^(?:[a-z0-9-_.:@]+)\$" "$bookmark"
    __fishamnium_print_error "Use only letters, numbers, and -, _, ., : and @ for the name."
    return 
  end

  if set existing (bookmark_show $bookmark 2>/dev/null)
    __fishamnium_print_error "The bookmark \x1b[0m\x1b[1m$bookmark\x1b[31m\x1b[22m already exists and points to \x1b[0m\x1b[1m$existing\x1b[31m\x1b[22m."
    return 1
  end

  # Save the element
  set newElement (printf '[{"name": "%s", "bookmark": "%s", "rootPath": "%s", "paths": [], "group": ""}]' "$name" "$bookmark" "$destination")
  
  if ! yq --inplace -o json ". + $newElement" ~/.fishamnium_bookmarks.json 2>/dev/null
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
    __fishamnium_print_error "The bookmark \x1b[0m\x1b[1m$bookmark\x1b[31m\x1b[22m does not exists."
    return 1
  end

  # Remove the bookmark from the file
  if ! yq --inplace -o json "del(.[] | select(.bookmark == \"$bookmark\"))" ~/.fishamnium_bookmarks.json 2>/dev/null
    __fishamnium_print_error "Cannot delete the bookmark."
    return 1
  end
end

function bookmark_cd -d "Changes current directory to a saved bookmark"
  if ! set destination (bookmark_show $argv 2>/dev/null)
    echo $destination
    return 1
  end

  cd "$destination"
end

function bookmark_open -d "Edits a bookmark using the current editor"
  if ! set destination (bookmark_show $argv 2>/dev/null)
    echo $destination
    return 1
  end

  $GEDITOR "$destination"
end

function bookmark_edit -d "Edits a bookmark using the current terminal editor"
  if ! set destination (bookmark_show $argv 2>/dev/null)
    echo $destination
    return 1
  end

  $EDITOR "$destination"
end

alias l=bookmarks_list
alias b=bookmark_show
alias s=bookmark_save
alias d=bookmark_delete
alias c=bookmark_cd
alias o=bookmark_open
alias e=bookmark_edit

