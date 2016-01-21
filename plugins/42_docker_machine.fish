#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function docker_setup --description "Setup Docker Machine environment"
  if test "$argv[1]" = "-h";
    echo "Usage: docker_setup [NAME]"
    echo "The default name is name."
    return 1
  end

  echo $argv | read -l name
  test -z "$name"; and set -l name "main"

  which docker-machine > /dev/null; and eval (docker-machine env $name);
  set -x -g DOCKER_IP (echo $DOCKER_HOST | sed -E "s#.+/(.+):.+#\1#")
end

docker_setup
