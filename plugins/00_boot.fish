# Set up config file path
set -x -g FISHAMNIUM_CONFIG "$HOME/.config/fishamnium/config.yml"

# Set some common directories
for root in /usr/local /opt /opt/homebrew /var
  for dir in $root/bin $root/sbin
    test -d $dir; and set -x -g PATH $dir $PATH
	end
end

# Set the bin in the current directory
set -x -g PATH ./bin $PATH
