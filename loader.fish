# Set defaults
set -x -g FISHAMNIUM_VERSION $(cat ~/.local/share/fishamnium/version)

test $(count $FISHAMNIUM_PLUGINS) -eq 0; and set -x FISHAMNIUM_PLUGINS $(command ls ~/.local/share/fishamnium/plugins/*.fish | xargs -n1 basename)
test $(count $FISHAMNIUM_COMPLETIONS) -eq 0; and set -x FISHAMNIUM_COMPLETIONS $(command ls ~/.local/share/fishamnium/completions/*.fish | xargs -n1 basename)
test -n $FISHAMNIUM_THEME; and set -x FISHAMNIUM_THEME default

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

# Load theme using starship
set -x -g STARSHIP_CONFIG ~/.local/share/fishamnium/themes/$FISHAMNIUM_THEME.toml
starship init fish | source
