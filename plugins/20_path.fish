#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# Set the bin in the current directory
set -x -g PATH ./bin $PATH

for root in /usr/local /opt /var
	if test -d $root
    for dir in $root/bin $root/sbin
			test -d $dir; and set -x -g PATH $dir $PATH
		end
	end
end
