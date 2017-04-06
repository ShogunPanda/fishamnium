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
helpers = ["fishamnium_bookmarks", "fishamnium_git"]
external_scripts = {
  # name => [path, url]
}

desc "Releases a new version."
task :release, :version, :changelog do |_, args|
  version = args[:version].to_s
  changelog = args[:changelog].to_s
  raise RuntimeError.new("You have to specify the version of the release.") if version.length == 0

  File.write("CHANGELOG.md", "### #{Time.now.strftime("%F")} - #{version}\n\n* #{changelog}\n\n" + File.read("CHANGELOG.md")) if changelog.length > 0
  File.write("loader.fish", File.read("loader.fish").gsub(/set -x -g FISHAMNIUM_VERSION.+/, "set -x -g FISHAMNIUM_VERSION \"#{version}\""))

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