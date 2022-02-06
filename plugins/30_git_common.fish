#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function __g_status
	if test -n "$dryRun"
		echo -e "\x1b[34m--> Would execute: \x1b[33m$argv\x1b[0m"
	else 
		echo -e "Executing: \x1b[33m--> $argv\x1b[0m"
	end
end

function __git
	__g_status git $argv

	if test -z "$dryRun"
  	git $argv
	end
end

function __g_open
	set cmd (g_open_path)
	__g_status $cmd $argv

	if test -z "$dryRun"
		$cmd $argv
	end
end

function __g_ensure_branch
	if test -n "$argv[1]"
    echo $argv[1]
  else
    g_default_branch
  end
end

function __g_ensure_remote
	if test -n "$argv[1]"
    echo $argv[1]
  else
    g_default_remote
  end
end

function g_default_branch --description "Get the default branch for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_DEFAULT_BRANCH"
		echo "$GIT_DEFAULT_BRANCH"
		return
	end

	# Lookup the value in the configuration file, with fallback
	__fishamnium_get_configuration .git.branch "main"
end

function g_default_remote --description "Get the default remote for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_DEFAULT_REMOTE"
		echo "$GIT_DEFAULT_REMOTE"
		return
	end

	# Lookup the value in the configuration file, with fallback
  __fishamnium_get_configuration .git.remote "origin"
end

function g_task_matchers --description "Get the task matchers for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_TASK_MATCHERS"
		echo "$GIT_TASK_MATCHERS"
		return
	end

	# Lookup the value in the configuration file, with fallback
	__fishamnium_get_configuration .git.taskMatchers "
  git@github\\.com:(?<repo>.+)\\.git https://github.com/@repo@/compare/@base@...@branch@?expand=1
  https://github\\.com/(?<repo>.+)\\.git https://github.com/@repo@/compare/@base@...@branch@?expand=1
  git@gitlab\\.com:(?<repo>.+)\\.git https://gitlab.com/@repo@/merge_requests/new?merge_request%5Btarget_branch%5D=@base@&merge_request%5Bsource_branch%5D=@branch@
  https://gitlab\\.com/(?<repo>.+)\\.git.git https://gitlab.com/@repo@/merge_requests/new?merge_request%5Btarget_branch%5D=@base@&merge_request%5Bsource_branch%5D=@branch@
  "
end

function g_task_template --description "Get the task template for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_TASK_TEMPLATE"
		echo "$GIT_TASK_TEMPLATE"
		return
	end

	# Lookup the value in the configuration file, with fallback
	__fishamnium_get_configuration .git.taskTemplate "@message@ [#@task@]"
end

function g_open_path --description "Get the Pull Request open command for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_OPEN_PATH"
		echo "$GIT_OPEN_PATH"
		return
	end

	# Lookup the value in the configuration file, with fallback
	__fishamnium_get_configuration .git.openPath "/usr/bin/open"
end

function g_release_prefix --description "Get the release prefix for the current repository"
	# Return the value for the environment variables, if any
	if test -n "$GIT_RELEASE_PREFIX"
		echo "$GIT_RELEASE_PREFIX"
		return
	end

	# Lookup the value in the configuration file, with fallback
	__fishamnium_get_configuration .git.releasePrefix "release-"
end