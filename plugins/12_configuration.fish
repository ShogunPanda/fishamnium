function __fishamnium_find_configuration_file
	# Parse arguments
	set fileName $argv[1]
	set -q fileName; or set fileName .fishamnium.yml
	
	# Traverse up to the root to find a matching file
	set origPwd $PWD
	while test "$PWD" != "$lastPwd";
		# There is a match, store and break
		if test -f "$PWD/$fileName"
			set configurationPath "$PWD/$fileName"
			break
		end

		# Continue traversing
		set lastPwd $PWD
		cd ..
	end

	# Restore the original working directory and return
	cd $origPwd
	set -q configurationPath; or return 1
	echo $configurationPath
end

function __fishamnium_get_configuration
	set selector $argv[1]
	set fallback $argv[2]
	# Read the value from a configuration file, if any
	if set configurationPath (__fishamnium_find_configuration_file)
		set value (yq "$selector" $configurationPath 2>/dev/null)
	end

	# Return the value or the fallback
	test -n "$value"; and echo $value; or echo "$fallback"
end