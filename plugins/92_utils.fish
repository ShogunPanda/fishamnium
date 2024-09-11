function execute_on_list
  set orig_pwd $PWD
  argparse -i --name=execute_on_list "l/list" "x/execute" "c/continue" -- $argv

  if set -q _flag_l
    set list $(string split " " "$argv[1]")
  else if set -q _flag_x
    set list $(eval $argv[1])
  else
    set list $(cat $argv[1])
  end

  for item in $list
    string match -qr -- "^#" "$item"; and continue;

    echo -e "$FISHAMNIUM_COLOR_PRIMARY--> Executing on directory $FISHAMNIUM_COLOR_BOLD$item$FISHAMNIUM_COLOR_NORMAL ...$FISHAMNIUM_COLOR_RESET"
    cd $item
    eval $argv[2..]

    if test $status -ne 0;
      if ! set -q _flag_c
        cd $orig_pwd
        echo -e "$FISHAMNIUM_COLOR_ERROR--> Aborting due to non zero exit code.$FISHAMNIUM_COLOR_RESET"
        return 1
      end
    end

    cd $orig_pwd
  end

  echo -e "$FISHAMNIUM_COLOR_SUCCESS--> All operations completed successfully.$FISHAMNIUM_COLOR_RESET"
end

function cd_project_root
  argparse -i --name=cd_project_root "N/dry-run" -- $argv

  set destination $(path dirname "$PWD")

  while test $destination != "/"
    set destination $(path dirname "$destination")

    set is_root 0

    for file in package.json Cargo.toml Makefile go.mod README.md;
     if test -e $destination/$file;
       set is_root 1
     end
    end

    if test $is_root -eq 1;
      break;
    end
  end

  if test $destination = "/";
    echo -e "$FISHAMNIUM_COLOR_ERROR--> No projects found.$FISHAMNIUM_COLOR_RESET"
    return 0
  end

  if test -z $_flag_N
		echo -e "$FISHAMNIUM_COLOR_PRIMARY--> Moving to $FISHAMNIUM_COLOR_RESET$destination$FISHAMNIUM_COLOR_PRIMARY ...$FISHAMNIUM_COLOR_RESET"
    cd $destination
	else
		echo -e "$FISHAMNIUM_COLOR_SECONDARY--> Would move to $FISHAMNIUM_COLOR_RESET$destination$FISHAMNIUM_COLOR_SECONDARY.$FISHAMNIUM_COLOR_RESET"
  end
end
