function __fishamnium_update_starship_config
  set -l theme $FISHAMNIUM_THEME

  if test -n "$COLUMNS"; and test $COLUMNS -lt $FISHAMNIUM_THEME_NARROW_THRESHOLD
    set theme $FISHAMNIUM_THEME_NARROW
  end

  set -x -g STARSHIP_CONFIG ~/.local/share/fishamnium/themes/$theme.toml
end

# Set defaults
set -x -g FISHAMNIUM_VERSION $(cat ~/.local/share/fishamnium/version)

test $(count $FISHAMNIUM_PLUGINS) -eq 0; and set -x FISHAMNIUM_PLUGINS $(command ls ~/.local/share/fishamnium/plugins/*.fish | xargs -n1 basename)
test $(count $FISHAMNIUM_COMPLETIONS) -eq 0; and set -x FISHAMNIUM_COMPLETIONS $(command ls ~/.local/share/fishamnium/completions/*.fish | xargs -n1 basename)

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
set -q FISHAMNIUM_THEME; or set -x -g FISHAMNIUM_THEME default
set -q FISHAMNIUM_THEME_NARROW; or set -x -g FISHAMNIUM_THEME_NARROW compact
set -q FISHAMNIUM_THEME_NARROW_THRESHOLD; or set -x -g FISHAMNIUM_THEME_NARROW_THRESHOLD 100
starship init fish --print-full-init | string replace -r -a '^(\s*set STARSHIP_JOBS .*)$' '$1; __fishamnium_update_starship_config' | source
