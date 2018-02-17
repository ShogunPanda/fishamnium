#/usr/bin/env ruby
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "version"

def detect_version(lines)
  catch :version do
    lines.each_with_index do |l, i|
      mo = /set -x -g FISHAMNIUM_VERSION \"(?<version>.+)\"/i.match(l)
      throw(:version, [i, mo[:version].to_version]) if mo
    end

    [-1, "1.0.0".to_version]
  end
end

desc "Build the helper and prepare the dist folder."
task :build => [:clean, "build:shell"] do
  ENV["GOARCH"] = "amd64"

  # Compile the executables
  ["darwin", "linux", "windows"].each do |os|
    ENV["GOOS"] = os
    cmd = "go build -o dist/helpers/fishamnium-#{os} -ldflags='-s -w'"
    puts cmd
    system(cmd)
  end
end

namespace :build do
  desc "Build the shell and prepare the dist folder."
  task :shell do
    FileUtils.mkdir_p("dist", verbose: true)

    # Copy shell scripts
    FileUtils.cp_r(Dir.glob("shell/*"), "dist", verbose: true)
  end
end

desc "Releases the software."
task :release do
  lines = File.readlines("shell/loader.fish").map {|l| l }
  version = detect_version(lines)

  ["git tag -f v#{version[1]}", "git push origin", "git push origin -f --tags"].each do |cmd|
    puts cmd
    system(cmd)
  end
end

namespace :release do
  desc "Updates the version and updates the CHANGELOG.md file"
  task :change, [:version] do |_, args|
    version = args[:version]
    changelog = args.extras

    lines = File.readlines("shell/loader.fish").map {|l| l }

    # Find current version
    current_version = detect_version(lines)

    if version && !version.empty? # Upgrade the version
      if version =~ /patch|minor|major/
        version = "revision" if version == "patch"
        current_version[1].bump!(version.to_sym)
      else
        current_version[1] = version.to_version
      end

      lines[current_version[0]] = "set -x -g FISHAMNIUM_VERSION \"#{current_version[1]}\"\n"
      File.write("shell/loader.fish", lines.join(""))

      changelog = ["Version #{current_version[1]}"] if changelog.empty?
    end

    if !changelog.empty? # There is a changelog entry, insert it
      entries = changelog.map {|c| "* #{c}" }
      entry = "### #{Time.now.strftime("%F")} / #{current_version[1]}\n\n#{entries.join("\n")}"

      File.write("./CHANGELOG.md", "#{entry}\n\n#{File.read("./CHANGELOG.md")}")
    end

    system('git add -A')
    system('git commit -a -m "Updated CHANGELOG.md"')
  end
end

desc "Cleans the build directories."
task :clean do
  FileUtils.rm_rf(["dist"], verbose: true)
end

desc "Verifies the code."
task :lint do
  Kernel.exec("go vet")
end

task default: ["build"]
