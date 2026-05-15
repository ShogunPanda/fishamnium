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

    printf "%s%s--> Executing on directory %s%s%s ...%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$FISHAMNIUM_COLOR_BOLD" "$item" "$FISHAMNIUM_COLOR_NORMAL" "$FISHAMNIUM_COLOR_RESET"
    cd $item
    eval $argv[2..]

    set current_status $status
    if test $status -ne 0;
      if ! set -q _flag_c
        cd $orig_pwd
        printf "%s%s--> Aborting due to non zero exit code (%s%s%s) on directory %s%s%s.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_BOLD" "$current_status" "$FISHAMNIUM_COLOR_NORMAL" "$FISHAMNIUM_COLOR_BOLD" "$item" "$FISHAMNIUM_COLOR_NORMAL" "$FISHAMNIUM_COLOR_RESET"
        return 1
      end
    end

    cd $orig_pwd
  end

  printf "%s%s--> All operations completed successfully.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_SUCCESS" "$FISHAMNIUM_COLOR_RESET"
end
