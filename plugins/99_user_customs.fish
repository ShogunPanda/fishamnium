test -x $HOME/.fishamnium_profile; and . $HOME/.fishamnium_profile

for i in $HOME/.fishamnium.d/*.fish;
  test -x $i; and source $i
end

for i in $HOME/.config/fishamnium/*.fish
  test -x $i; and source $i
end

set -g FISHAMNIUM_DIRHOOK_CURRENT $PWD

function __fishamnium_dirhook --on-variable PWD
  # Check for a fishamnium file in the new directory
  set -l new_directory $PWD
  if ! test -x $new_directory/.fishamnium.fish

    # Check for a fishamnium file in the project root
    set root $(project_root)

    if test $status -eq 0
      set new_directory $root      
    end
  end

  if test $new_directory = $FISHAMNIUM_DIRHOOK_CURRENT
    set -e FISHAMNIUM_DIRHOOK_OPERATION
    return
  end

  # Unload the previous directory hook if any
  if test -x $FISHAMNIUM_DIRHOOK_CURRENT/.fishamnium.fish
    set -g FISHAMNIUM_DIRHOOK_OPERATION "leave"
    source $FISHAMNIUM_DIRHOOK_CURRENT/.fishamnium.fish
    set -e FISHAMNIUM_DIRHOOK_OPERATION
  end

  set -g FISHAMNIUM_DIRHOOK_CURRENT $PWD

  if test -x $new_directory/.fishamnium.fish
    set -g FISHAMNIUM_DIRHOOK_OPERATION "enter"
    source $new_directory/.fishamnium.fish
    set -e FISHAMNIUM_DIRHOOK_OPERATION
  end

  set -e FISHAMNIUM_DIRHOOK_OPERATION
end