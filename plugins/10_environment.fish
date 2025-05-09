set -x -g EDITOR "nvim"
set -x -g GEDITOR "code"
set -x -g fish_greeting

function fishamnium_reload -d "Reloads Fishamnium"
  echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_PRIMARY--> Reloading Fishamnium ...$FISHAMNIUM_COLOR_RESET"
  source ~/.config/fish/conf.d/fishamnium.fish
end

function fishamnium_forced_reload -d "Reloads Fishamnium (forced)"
  set -x FISHAMNIUM_PLUGINS FISHAMNIUM_COMPLETIONS FISHAMNIUM_LOADED_PLUGINS FISHAMNIUM_LOADED_COMPLETIONS
  fishamnium_reload
end

function fishamnium_update -d "Updates Fishamnium"
  rm ~/.config/fish/fishamnium ~/.config/fish/conf.d/fishamnium.fish
  curl -sL https://sw.cowtech.it/fishamnium/installer | fish
  fishamnium_forced_reload
end

which direnv > /dev/null
test $status -eq 0; and direnv hook fish | source

