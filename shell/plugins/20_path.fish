#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

for root in /usr/local /opt /var
  for dir in $root/bin $root/sbin
    test -d $dir; and set -x -g PATH $dir $PATH
	end
end

set -x -g PATH $PATH ~/.fishamnium/helpers
