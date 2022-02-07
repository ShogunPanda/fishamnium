set -x -g EDITOR "nano"
set -x -g GEDITOR "code"
set -x -g fish_greeting

function fishamnium_reload -d "Reloads Fishamnium"
  echo -e "\x1b[33m--> Reloading Fishamnium ...\x1b[0m"
  source ~/.config/fish/conf.d/fishamnium.fish
end