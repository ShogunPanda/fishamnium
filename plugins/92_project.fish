function project_root
  set destination $PWD

  argparse -i --name=project_root "N/dry-run" "c/include-current" "y/copy" -- $argv

  if ! set -q _flag_c
    set destination $(path dirname "$destination")
  end

  while test $destination != "/"
    set is_root 0

    for file in package.json Cargo.toml Makefile go.mod README.md;
      if test -e $destination/$file;
        set is_root 1
      end
    end

    if test $is_root -eq 1;
      break;
    end

    set destination $(path dirname "$destination")
  end

  if test $destination = "/";
    if ! set -q _flag_y
      printf "%s%s--> No projects found.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_RESET"
    end

    return 1
  end

  if set -q _flag_y
    echo -n "$destination" | fish_clipboard_copy
  else
    echo $destination
  end
end


function cd_project_root
  # Drop the copy flag
  argparse -i --name=cd_project_root "y/copy" -- $argv

  # Get the project directory
  set destination $(project_root $argv)

  if test $status -ne 0
    printf "%s%s--> No projects found.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_RESET"
    return 1
  end

  # Use the result
  argparse -i --name=cd_project_root "N/dry-run" -- $argv

  if set -q _flag_N
    printf "%s%s--> Would move to %s%s%s.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_SECONDARY" "$FISHAMNIUM_COLOR_RESET" "$destination" "$FISHAMNIUM_COLOR_FG_SECONDARY" "$FISHAMNIUM_COLOR_RESET"
  else
    printf "%s%s--> Moving to %s%s%s ...%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$FISHAMNIUM_COLOR_RESET" "$destination" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$FISHAMNIUM_COLOR_RESET"
    cd $destination
  end
end

alias p=project_root
alias cdr=cd_project_root
