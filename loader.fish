# Set defaults
set -x -g FISHAMNIUM_VERSION (string trim (string collect < ~/.local/share/fishamnium/version))

test $(count $FISHAMNIUM_PLUGINS) -eq 0; and set -x FISHAMNIUM_PLUGINS (path basename ~/.local/share/fishamnium/plugins/*.fish)
test $(count $FISHAMNIUM_COMPLETIONS) -eq 0; and set -x FISHAMNIUM_COMPLETIONS (path basename ~/.local/share/fishamnium/completions/*.fish)

# Load plugins files
set -e -g FISHAMNIUM_LOADED_PLUGINS
for i in $(string split " " "$FISHAMNIUM_PLUGINS")
  set source ~/.local/share/fishamnium/plugins/$i
  
  if test -x $source
    set -x -g FISHAMNIUM_LOADED_PLUGINS $FISHAMNIUM_LOADED_PLUGINS $i
    source $source
  end
end

# Load completions files
set -e -g FISHAMNIUM_LOADED_COMPLETIONS
for i in $(string split " " "$FISHAMNIUM_COMPLETIONS")
  set source ~/.local/share/fishamnium/completions/$i
  
  if test -x $source
    set -x -g FISHAMNIUM_LOADED_COMPLETIONS $FISHAMNIUM_LOADED_COMPLETIONS $i
    source $source
  end
end

function fish_prompt
  $FISHAMNIUM_HELPER prompt --status "$status" --duration "$CMD_DURATION" --width "$COLUMNS" --path "$PWD"
end
