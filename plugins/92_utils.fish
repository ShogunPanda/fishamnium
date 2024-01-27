function execute_on_list
  set orig_pwd $PWD
  argparse -i --name=execute_on_list "x/execute" -- $argv

  if test -z $_flag_x
    set list $(cat $argv[1])
  else
    set list $(eval $argv[1])
  end

  for item in $list
    string match -qr -- "^#" "$item"; and continue;

    echo -e "\x1b[33m--> Executing on directory \x1b[1m$item\x1b[22m ...\x1b[0m"
    cd $item
    eval $argv[2..]

    if test $status -ne 0;
      cd $orig_pwd
      echo -e "\x1b[31m--> Aborting due to non zero exit code.\x1b[0m"
      return 1
    end

    cd $orig_pwd
  end

  echo -e "\x1b[32m--> All operations completed successfully.\x1b[0m"
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
    echo -e "\x1b[31m--> No projects found.\x1b[0m"
    return 0
  end

  if test -z $_flag_N
		echo -e "\x1b[33m--> Moving to \x1b[0m$destination\x1b[33m ...\x1b[0m"
    cd $destination
	else 
		echo -e "\x1b[34m--> Would move to \x1b[0m$destination\x1b[34m.\x1b[0m"
  end
end