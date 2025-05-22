function project_root
  set destination $PWD

  argparse -i --name=project_root "N/dry-run" "s/skip-current" "y/copy" -- $argv

  if set -ql _flag_s
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
    if ! set -ql $flag_y
      echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_ERROR--> No projects found.$FISHAMNIUM_COLOR_RESET"
    end

    return 1
  end

  if set -ql $flag_y
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

  # Use the result
  argparse -i --name=cd_project_root "N/dry-run" -- $argv

  if test -z "$destination"
    echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_ERROR--> No projects found.$FISHAMNIUM_COLOR_RESET"
    return 0
  end

  if set -ql $flag_N
		echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_PRIMARY--> Moving to $FISHAMNIUM_COLOR_RESET$destination$FISHAMNIUM_COLOR_PRIMARY ...$FISHAMNIUM_COLOR_RESET"
    cd $destination
	else
		echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_SECONDARY--> Would move to $FISHAMNIUM_COLOR_RESET$destination$FISHAMNIUM_COLOR_SECONDARY.$FISHAMNIUM_COLOR_RESET"
  end
end

alias p=project_root
alias cdr=cd_project_root
