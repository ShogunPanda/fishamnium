# Set up config file path
set -x -g FISHAMNIUM_ROOT "$HOME/.local/share/fishamnium"
set -x -g FISHAMNIUM_CONFIG_ROOT "$HOME/.config/fishamnium"
set -x -g FISHAMNIUM_HOST $(hostname -s)

if test -f "$FISHAMNIUM_CONFIG_ROOT/config.$FISHAMNIUM_HOST.yml"
  set -x -g FISHAMNIUM_CONFIG "$FISHAMNIUM_CONFIG_ROOT/config.$FISHAMNIUM_HOST.yml"
else
  set -x -g FISHAMNIUM_CONFIG "$FISHAMNIUM_CONFIG_ROOT/config.yml"
end


# Set some common directories
for root in /usr/local /opt /opt/homebrew /var
  for dir in $root/bin $root/sbin
    test -d $dir; and set -x -g PATH $dir $PATH
	end
end

# Set the bin in the current directory
set -x -g PATH ./bin $PATH
