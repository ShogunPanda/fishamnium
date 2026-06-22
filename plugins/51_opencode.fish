
function opencode_session_delete_select -d "Interactively delete opencode sessions"
  set sessions $(opencode session list --format json | yq ".[].id")
  set prompt "--> Which sessions do you want to delete?"
  set height $(math $(count $sessions) + 3)

  set choices $(string join0 $sessions | __fishamnium_multiselect "$prompt" "$height")
  
  if test $status -eq 0
    for choice in $choices
      opencode session delete $choice
    end
  end
end

function opencode_session_temporary -d "Create a temporary opencode session and deletes upon exit"
  opencode
  opencode session delete (opencode session list -n --format json | yq ".[0].id")
end

alias oc="opencode"
alias occ="opencode -c"
alias oct="opencode_session_temporary"
alias ocs="opencode session list"
alias ocd="opencode session delete"
alias ocds=opencode_session_delete_select
