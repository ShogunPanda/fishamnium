# ----- Writing functions -----

function opencode_attach -d "Attach to the configured OpenCode server"
  if set -q FISHAMNIUM_OPENCODE_SERVER_PORT
    opencode attach http://localhost:$FISHAMNIUM_OPENCODE_SERVER_PORT $argv
  else
    opencode $argv
  end
end

function opencode_session_open_select -d "Interactively opens a OpenCode sessions"
  argparse -i --name=opencode_session_open_select "a/attach" -- $argv

  if ! set sessions $($FISHAMNIUM_HELPER agents opencode list)
    return 1
  end

  if test (count $sessions) -eq 0
    return 1
  end

  if ! set choice $(printf "%s\n" $sessions | $FISHAMNIUM_HELPER select --prompt "Which session do you want to open" --raw)
    return 1
  end

  if test -z "$choice"
    return 1
  end

  set tab (printf "\t")
  set parts (string split -m 2 $tab "$choice")
  set session "$parts[1]"
  set directory "$parts[2]"
  set directory (string replace -r '^~(?=/|$)' "$HOME" -- "$directory")

  if test -z "$directory"
    __fishamnium_print_error "OpenCode session directory not found: $session"
    return 1
  end

  cd "$directory"; or return 1
  if set -q _flag_a
    opencode_attach -s "$session"
  else
    opencode -s "$session"
  end
end

function opencode_session_delete_select -d "Interactively delete OpenCode sessions"
  argparse -i --name=opencode_session_delete_select "g/global" -- $argv

  if set -q _flag_g
    if ! set sessions $($FISHAMNIUM_HELPER agents opencode list)
      return 1
    end
  else
    if ! set sessions $($FISHAMNIUM_HELPER agents opencode list "$PWD")
      return 1
    end
  end

  set choices $(string join0 $sessions | $FISHAMNIUM_HELPER select --prompt "Which sessions do you want to delete" --multi)
  
  if test $status -eq 0
    for choice in $choices
      opencode session delete $choice
    end
  end
end

function opencode_session_delete_last -d "Delete last OpenCode session"
  argparse -i --name=opencode_session_delete_select "g/global" -- $argv

  if set -q _flag_g
    opencode session delete ($FISHAMNIUM_HELPER agents opencode last)
    
  else
    opencode session delete ($FISHAMNIUM_HELPER agents opencode last "$PWD")    
  end
end

function opencode_session_temporary -d "Create a temporary OpenCode session and deletes upon exit"
  argparse -i --name=opencode_session_temporary "a/attach" -- $argv

  if set -q _flag_a
    opencode_attach
  else
    opencode
  end
  opencode_session_delete_last
end

# ----- Aliases -----

alias oc="opencode"
alias occ="opencode -c"
alias ocs="opencode -s"
alias ocss="opencode_session_open_select"
alias oct="opencode_session_temporary"

alias oca="opencode_attach"
alias ocac="opencode_attach -c"
alias ocas="opencode_attach -s"
alias ocass="opencode_session_open_select -a"
alias ocat="opencode_session_temporary -a"

alias ocl="opencode session list"
alias ocd="opencode session delete"
alias ocdl=opencode_session_delete_last
alias ocdlg="opencode_session_delete_last -g"
alias ocds=opencode_session_delete_select
alias ocdg="opencode_session_delete_select -g"
