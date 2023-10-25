function execute_on_list
  set orig_pwd $PWD

  for item in $(cat $argv[1])
    string match -qr -- "^#" "$item"; and continue;

    echo "--- $item ---"
    cd $item
    eval $argv[2..]
    cd $orig_pwd
  end
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