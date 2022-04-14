
function __fishamnium_conditional_load
  which $argv[1] >/dev/null 2>/dev/null; and chmod u+x ~/.config/fish/fishamnium/plugins/$argv[2].fish; or chmod u-x ~/.config/fish/fishamnium/plugins/$argv[2].fish  
end

# Set defaults
set -x -g FISHAMNIUM_VERSION "9.7.1"

test (count $FISHAMNIUM_PLUGINS) -eq 0; and set -x FISHAMNIUM_PLUGINS (command ls ~/.config/fish/fishamnium/plugins/*.fish | xargs -n1 basename)
test (count $FISHAMNIUM_COMPLETIONS) -eq 0; and set -x FISHAMNIUM_COMPLETIONS (command ls ~/.config/fish/fishamnium/completions/*.fish | xargs -n1 basename)
test -n $FISHAMNIUM_THEME; and set -x FISHAMNIUM_THEME default

# Conditionally load plugins
__fishamnium_conditional_load n 41_node_n
__fishamnium_conditional_load npm 42_npm
__fishamnium_conditional_load rbenv 51_ruby
__fishamnium_conditional_load bundle 52_bundler
__fishamnium_conditional_load rails 53_rails

# Load plugins files
set -e -g FISHAMNIUM_LOADED_PLUGINS
for i in (string split " " "$FISHAMNIUM_PLUGINS")
  set source ~/.config/fish/fishamnium/plugins/$i
  
  if test -x $source
    set -x -g FISHAMNIUM_LOADED_PLUGINS $FISHAMNIUM_LOADED_PLUGINS $i
    source $source
  end
end

# Load completions files
set -e -g FISHAMNIUM_LOADED_COMPLETIONS
for i in (string split " " "$FISHAMNIUM_COMPLETIONS")
  set source ~/.config/fish/fishamnium/completions/$i
  
  if test -x $source
    set -x -g FISHAMNIUM_LOADED_COMPLETIONS $FISHAMNIUM_LOADED_COMPLETIONS $i
    source $source
  end
end

# Load theme using starship
set -x -g STARSHIP_CONFIG ~/.config/fish/fishamnium/themes/$FISHAMNIUM_THEME.toml
starship init fish | source