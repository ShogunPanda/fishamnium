#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __rails_wants_command
  [ (commandline -opc) = "rails" ]; and return 0;
  return 1;
end

function __is_rails_console
  set cmd (commandline -opc)
  contains c $cmd; and return 0;
  contains console $cmd; and return 0;
  return 1;
end

function __is_rails_server
  set cmd (commandline -opc)
  contains s $cmd; and return 0;
  contains server $cmd; and return 0;
  return 1;
end

function __rails_environments
  /bin/ls config/environments/ ^ /dev/null | sed "s#.rb\$##g"
end

complete -c rails -n "__rails_wants_command" -f -a server --description "Starts the Rails server."
complete -c rails -n "__rails_wants_command" -f -a s --description "Starts the Rails server."
complete -c rails -n "__rails_wants_command" -f -a console --description "Starts the Rails console."
complete -c rails -n "__rails_wants_command" -f -a c --description "Starts the Rails console."
complete -c rails -n "__is_rails_server" -x -s p -l port
complete -c rails -n "__is_rails_server" -x -s e -l environment -a "(__rails_environments)"
complete -c rails -n "__is_rails_console" -a "(__rails_environments)"

complete -c rs -x -s p -l port
complete -c rs -x -s e -l environment -a "(__rails_environments)"
complete -c rc -f -a "(__rails_environments)"