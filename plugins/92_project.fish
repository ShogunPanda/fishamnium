function project_root
  set fallback $PWD
  set destination $PWD

  argparse -i --name=project_root "N/dry-run" "c/include-current" "f/fallback" "q/quiet" "y/copy" -- $argv

  if ! set -q _flag_c
    set destination $(path dirname "$destination")
  end

  while test $destination != "/"
    set is_root 0

    for file in package.json Makefile.toml Cargo.toml Makefile go.mod README.md;
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
    if set -q _flag_f
      set destination $fallback
    else
      if ! set -q _flag_q; and ! set -q _flag_y
        printf "%s%s--> No projects found.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_RESET"
      end

      return 1
    end
  end

  if set -q _flag_y
    echo -n "$destination" | fish_clipboard_copy
  else
    echo $destination
  end
end

function project_roots
  set destination $PWD

  argparse -i --name=project_roots "c/include-current" "q/quiet" "y/copy" -- $argv

  if ! set -q _flag_c
    set destination $(path dirname "$destination")
  end

  set roots

  while test $destination != "/"
    set is_root 0

    for file in package.json Makefile.toml Cargo.toml Makefile go.mod README.md;
      if test -e $destination/$file;
        set is_root 1
      end
    end

    if test $is_root -eq 1;
      set roots $roots $destination
    end

    set destination $(path dirname "$destination")
  end

  if test (count $roots) -eq 0
    if ! set -q _flag_q; and ! set -q _flag_y
      printf "%s%s--> No projects found.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_RESET"
    end

    return 1
  end

  if set -q _flag_y
    printf "%s\n" $roots | fish_clipboard_copy
  else
    printf "%s\n" $roots
  end
end

function project_type
  set root $argv[1]

  if test -z "$root"
    set root $(project_root -c -f)

    if test $status -ne 0
      return 1
    end
  end

  if test -e "$root/package.json"
    echo javascript
  else if test -e "$root/Makefile.toml"
    echo makers
  else if test -e "$root/Cargo.toml"
    echo rust
  else if test -e "$root/Makefile"
    echo make
  else
    echo shell
  end
end

function project_runner
  set type $(project_type $argv[1])

  if test $status -ne 0
    return 1
  end

  switch $type
    case javascript
      echo npm
    case makers
      echo makers
    case rust
      echo cargo
    case make
      echo make
    case shell
      echo bash
  end
end

function project_build
  set runner $(project_runner $argv[1])

  if test $status -ne 0
    return 1
  end

  switch $runner
    case npm
      npm run build
    case makers
      makers build
    case cargo
      cargo build
    case make
      make build
    case bash
      bash build.sh
  end
end

function project_test
  set runner $(project_runner $argv[1])

  if test $status -ne 0
    return 1
  end

  switch $runner
    case npm
      npm run test
    case makers
      makers test
    case cargo
      cargo test
    case make
      make test
    case bash
      bash test.sh
  end
end


function project_deploy
  set runner $(project_runner)

  if test $status -ne 0
    return 1
  end

  switch $runner
    case npm
      npm run deploy
    case makers
      makers deploy
    case cargo
      printf "%s%sDeploy is not supported for Rust projects.%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$FISHAMNIUM_COLOR_RESET"
      return 1
    case make
      make deploy
    case bash
      bash deploy.sh
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
alias pmt=project_type
alias pmr=project_runner
alias pb=project_build
alias pt=project_test
alias pd=project_deploy
alias cdr=cd_project_root
