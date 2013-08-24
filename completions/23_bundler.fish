#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __bundle_wants_command
  [ (commandline -opc) = "bundle" ]; and return 0;
  return 1;
end

function __bundle_wants_gem
  set cmd (commandline -opc)

  if test -f Gemfile;
    if contains show $cmd; return 0; end;
    if contains update $cmd; return 0; end;
  end;

  return 1;
end

function __bundle_gems
  test -f Gemfile; and cat Gemfile | grep -E "^\s+gem" | awk '{ print $2 }' | sed -e 's#[,"]##g';
end

complete -c bundle -n "__bundle_wants_command" -f -a check --description "Checks if the dependencies listed in Gemfile are satisfied"
complete -c bundle -n "__bundle_wants_command" -f -a clean --description "Cleans up unused gems in your bundler directory"
complete -c bundle -n "__bundle_wants_command" -f -a config --description "Retrieve or set a configuration value"
complete -c bundle -n "__bundle_wants_command" -f -a console --description "Opens an IRB session with the bundle pre-loaded"
complete -c bundle -n "__bundle_wants_command" -f -a exec --description "Run the command in context of the bundle"
complete -c bundle -n "__bundle_wants_command" -f -a gem --description "Creates a skeleton for creating a rubygem"
complete -c bundle -n "__bundle_wants_command" -f -a help --description "Displays detailed help for each subcommand"
complete -c bundle -n "__bundle_wants_command" -f -a init --description "Generates a Gemfile into the current working directory"
complete -c bundle -n "__bundle_wants_command" -f -a install --description "Install the current environment to the system"
complete -c bundle -n "__bundle_wants_command" -f -a open --description "Opens the source directory of the given bundled gem"
complete -c bundle -n "__bundle_wants_command" -f -a outdated --description "List installed gems with newer versions available"
complete -c bundle -n "__bundle_wants_command" -f -a package --description "Locks and then caches all of the gems into vendor/cache"
complete -c bundle -n "__bundle_wants_command" -f -a platform --description "Displays platform compatibility information"
complete -c bundle -n "__bundle_wants_command" -f -a show --description "Shows all gems that are part of the bundle, or the path to a given gem"
complete -c bundle -n "__bundle_wants_command" -f -a update --description "Update the current environment"
complete -c bundle -n "__bundle_wants_command" -f -a version --description "Prints version information"
complete -c bundle -n "__bundle_wants_command" -f -a viz --description "Generates a visual dependency graph"
complete -c bundle -n "__bundle_wants_gem" -f -a "(__bundle_gems)"

complete -c bu -f -a "(__bundle_gems)"
complete -c bs -f -a "(__bundle_gems)"
