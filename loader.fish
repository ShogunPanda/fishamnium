# Set defaults
set -x -g FISHAMNIUM_VERSION (string trim (string collect < ~/.local/share/fishamnium/version))

# Load plugins files
set -e -g FISHAMNIUM_LOADED_PLUGINS
for source in ~/.local/share/fishamnium/plugins/*.fish
  set i (path basename "$source")
  
  if test -x $source
    set -x -g FISHAMNIUM_LOADED_PLUGINS $FISHAMNIUM_LOADED_PLUGINS $i
    source $source
  end
end

# Load completions files
set -e -g FISHAMNIUM_LOADED_COMPLETIONS
for source in ~/.local/share/fishamnium/completions/*.fish
  set i (path basename "$source")
  
  if test -x $source
    set -x -g FISHAMNIUM_LOADED_COMPLETIONS $FISHAMNIUM_LOADED_COMPLETIONS $i
    source $source
  end
end

function fish_prompt
  $FISHAMNIUM_HELPER prompt --status "$status" --duration "$CMD_DURATION" --width "$COLUMNS" --path "$PWD"
end
