# Project dirhook contract
#
# While sourcing .fishamnium.fish, fishamnium exposes a temporary context:
#
# - FISHAMNIUM_DIRHOOK_OPERATION:
#   Current operation. Either "enter" or "leave".
#
# - FISHAMNIUM_DIRHOOK_PROJECT_CURRENT:
#   Project root affected by the current operation.
#   On "enter", this is the project being entered.
#   On "leave", this is the project being left.
#
# - FISHAMNIUM_DIRHOOK_PROJECT_OTHER:
#   The other project root in a direct project-to-project transition.
#   It is unset when entering from outside a project or leaving to outside.
#
# These variables are only valid while .fishamnium.fish is being sourced.
# Prefer the fishamnium_dirhook_* helpers below in project files.

# ----- Internal functions -----

function __fishamnium_project_hook_clear_context
  set -e FISHAMNIUM_DIRHOOK_OPERATION
  set -e FISHAMNIUM_DIRHOOK_PROJECT_CURRENT
  set -e FISHAMNIUM_DIRHOOK_PROJECT_OTHER
end

function __fishamnium_project_hook_resolve_root
  for root in (project_roots -c -q)
    if test -x "$root/.fishamnium.fish"
      echo $root
      return
    end
  end

  return 1
end

function __fishamnium_project_hook --on-variable PWD
  set -l previous_root $__FISHAMNIUM_DIRHOOK_PROJECT_CURRENT
  set -l next_root (__fishamnium_project_hook_resolve_root)

  if test "$previous_root" = "$next_root"
    return
  end

  if test -n "$previous_root"; and test -x "$previous_root/.fishamnium.fish"
    set -g FISHAMNIUM_DIRHOOK_OPERATION leave
    set -g FISHAMNIUM_DIRHOOK_PROJECT_CURRENT $previous_root

    if test -n "$next_root"; and test "$next_root" != "$previous_root"
      set -g FISHAMNIUM_DIRHOOK_PROJECT_OTHER $next_root
    end

    source "$previous_root/.fishamnium.fish"
    __fishamnium_project_hook_clear_context
  end

  set -g __FISHAMNIUM_DIRHOOK_PROJECT_CURRENT $next_root

  if test -n "$next_root"; and test -x "$next_root/.fishamnium.fish"
    set -g FISHAMNIUM_DIRHOOK_OPERATION enter
    set -g FISHAMNIUM_DIRHOOK_PROJECT_CURRENT $next_root

    if test -n "$previous_root"; and test "$previous_root" != "$next_root"
      set -g FISHAMNIUM_DIRHOOK_PROJECT_OTHER $previous_root
    end

    source "$next_root/.fishamnium.fish"
    __fishamnium_project_hook_clear_context
  end

  __fishamnium_project_hook_clear_context
end

# ----- Reading functions -----

# Print the current dirhook operation: "enter" or "leave".
function fishamnium_dirhook_operation --description 'Print the current dirhook operation'
  echo $FISHAMNIUM_DIRHOOK_OPERATION
end

# Print the project root affected by the current operation.
function fishamnium_dirhook_project_current --description 'Print the current dirhook project root'
  echo $FISHAMNIUM_DIRHOOK_PROJECT_CURRENT
end

# Print the other project root in a project-to-project transition, if any.
function fishamnium_dirhook_project_other --description 'Print the other dirhook project root'
  echo $FISHAMNIUM_DIRHOOK_PROJECT_OTHER
end

# Return success when the current operation is "enter".
function fishamnium_dirhook_is_enter --description 'Test whether the current dirhook operation is enter'
  test "$FISHAMNIUM_DIRHOOK_OPERATION" = enter
end

# Return success when the current operation is "leave".
function fishamnium_dirhook_is_leave --description 'Test whether the current dirhook operation is leave'
  test "$FISHAMNIUM_DIRHOOK_OPERATION" = leave
end

# Join arguments with the current project root.
function fishamnium_dirhook_project_path --description 'Join paths with the current dirhook project root'
  path join "$FISHAMNIUM_DIRHOOK_PROJECT_CURRENT" $argv
end

# ----- Writing functions -----

# Export a variable on enter and erase it on leave.
function fishamnium_dirhook_export --description 'Export a variable for the current dirhook project' --argument-names name
  if fishamnium_dirhook_is_enter
    set -gx $name $argv
  else if fishamnium_dirhook_is_leave
    set -e $name
  end
end

# Create an alias on enter and erase it on leave.
function fishamnium_dirhook_alias --description 'Create an alias for the current dirhook project' --argument-names name
  if fishamnium_dirhook_is_enter
    alias $name="$argv[2..]"
  else if fishamnium_dirhook_is_leave
    functions --erase $name
  end
end

# ----- Bootstrap -----

for file in $HOME/.config/fishamnium/*.fish
  test -x "$file"; and source "$file"
end

set -g __FISHAMNIUM_DIRHOOK_PROJECT_CURRENT (__fishamnium_project_hook_resolve_root)
__fishamnium_project_hook_clear_context
__fishamnium_project_hook
