set -x -g EDITOR "nano"
set -x -g GEDITOR "code"
set -x -g fish_greeting

function fishamnium_reload -d "Reloads Fishamnium"
  echo -e "\x1b[33m--> Reloading Fishamnium ...\x1b[0m"
  source ~/.config/fish/conf.d/fishamnium.fish
end

function fishamnium_forced_reload -d "Reloads Fishamnium (forced)"
  set -x FISHAMNIUM_PLUGINS FISHAMNIUM_COMPLETIONS FISHAMNIUM_LOADED_PLUGINS FISHAMNIUM_LOADED_COMPLETIONS
  fishamnium_reload
end

which direnv > /dev/null
test $status -eq 0; and direnv hook fish | source

