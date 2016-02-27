#/usr/bin/env ruby
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "open-uri"
require "fileutils"

home = ENV["HOME"]
root = "#{home}/.fishamnium"
contents_directory = File.dirname(__FILE__)
quiet = (ENV["FISHAMNIUM_QUIET"] =~ /^(1|on|true|yes|t|y)$/i)
external_scripts = {
  "plugins.rvm" => ["plugins/21_rvm", "https://raw.githubusercontent.com/lunks/fish-nuggets/master/functions/rvm.fish"],
  "plugins.nvm" => ["plugins/41_nvm", "https://raw.githubusercontent.com/passcod/nvm-fish-wrapper/master/nvm.fish"],
  "plugins.fishmarks" => ["plugins/71_fishmarks", "https://raw.githubusercontent.com/techwizrd/fishmarks/master/marks.fish"],
  "completions.git" => ["completions/31_git", "https://raw.github.com/zmalltalker/fish-nuggets/master/completions/git.fish"]
}

desc "Releases a new version."
task :release, :version, :changelog do |_, args|
  version = args[:version].to_s
  changelog = args[:changelog].to_s
  raise RuntimeError.new("You have to specify the version of the release.") if version.length == 0

  File.write("CHANGELOG.md", "### #{Time.now.strftime("%F")} - #{version}\n\n* #{changelog}\n\n" + File.read("CHANGELOG.md")) if changelog.length > 0

  system("git tag -d v-#{version}")
  system("git add -A")
  system("git commit -a -m 'Version #{version}.'")
  system("git tag v-#{version}")
  system("git push -f github")
  system("git push -f github --tags")
end

namespace :external do
  desc "Updates an external script."
  task :update, :name do |_, args|
    script_arg = args[:name].to_s

    raise RuntimeError.new("External script #{script_arg} is not valid. Valid scripts are: #{external_scripts.keys.join(", ")}.") if !external_scripts[script_arg]
    final_script = external_scripts[script_arg]

    open(contents_directory + "/#{final_script[0]}.fish", "w", 0755) do |destination|
      open(final_script[1]) do |source|
        destination.write(source.read)
      end
    end
  end
end
desc "Installs the environment."
task :install do
  files = FileList["loader.fish", "completions", "plugins", "themes"]
  FileUtils.mkdir_p(root)
  FileUtils.cp_r(files, root, verbose: !quiet)
  FileUtils.chmod_R(0755, root, verbose: false) # Never show this due to https://bugs.ruby-lang.org/issues/8547

  puts <<-EOMESSAGE
-------
fishamnium has been installed. Enabling it is left to you.
To enable, add the following line to #{home}/.config/fish/config.fish:

. #{root}/loader.fish

To modify the behavior, modify the FISHAMIUM_PLUGINS, FISHAMIUM_COMPLETION and FISHAMIUM_THEME environment variables before that line.
Enjoy! ;)"
  EOMESSAGE
end

desc "Uninstalls the environment."
task :uninstall do
  FileUtils.rm_r(root, verbose: !quiet)
  puts <<-EOMESSAGE
-------
fishamnium has been uninstalled. Disabling it is left to you.
To disable, remove the following line from #{home}/.config/fish/config.fish:

. #{root}/loader.fish

Hope you liked it. Farewell! ;)"
  EOMESSAGE
end

namespace :external do
  desc "Updates an external script."
  task :update, :name do |_, args|
    script_arg = args[:name].to_s

    raise RuntimeError.new("You have to specify the name of script to update. Valid scripts are: #{external_scripts.keys.join(", ")}.") if script_arg.strip.length == 0
    raise RuntimeError.new("External script #{script_arg} is not valid. Valid scripts are: #{external_scripts.keys.join(", ")}.") if !external_scripts[script_arg]
    final_script = external_scripts[script_arg]

    open(contents_directory + "/#{final_script[0]}.fish", "w", 0755) do |destination|
      open(final_script[1]) do |source|
        destination.write(source.read)
      end
    end
  end
end

task default: ["install"]
