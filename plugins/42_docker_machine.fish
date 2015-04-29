#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

which docker-machine > /dev/null; and docker-machine env | source;
set -x DOCKER_IP (echo $DOCKER_HOST | sed -E "s#.+/(.+):.+#\1#")
