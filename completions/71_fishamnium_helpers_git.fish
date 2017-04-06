#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fishamnium_git_completion_is_global
  set cmd (commandline -opc)

  if [ (count $cmd) -eq 1 ]
    return 0
  else
    for c in $cmd[2..-1]
      switch $c
        # General options that can still take a command
        case "-n" "-v" "--dry-run" "--verbose"
          continue
        case "-V" "-h" "--version" "--help"
          return 1
        case "*"
          return 1
      end
    end
  end
end

function __fishamnium_git_completion_is_command
  set cmd (commandline -opc)

  if [ (count $cmd) -eq 1 ]
    return 1
  else
    for c in $cmd[2..-1]
      switch $c
        # General options that can still take a command on global
        case "-n" "-v" "--dry-run" "--verbose"
          continue
        case "-V" "-h" "--version" "--help"
          return 1
        case "*"
          [ "$c" = "$argv[1]" ]; and return 0; or return 1
      end
    end
  end
end

complete -c r -c fishamnium_git -e
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'is_repository' -d 'Check if the current directory is a GIT repository.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'is_dirty' -d 'Check if the current GIT repository has uncommitted changes.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'remotes' -d 'Show GIT remotes.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'full_branch_name' -d 'Get the full current branch name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'fbn' -d 'Get the full current branch name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'branch_name' -d 'Get the current branch name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'bn' -d 'Get the current branch name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'full_sha' -d 'Get the full current GIT SHA.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'sha' -d 'Get the current GIT SHA.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'task' -d 'Get the current task name from the branch name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 't' -d 'Get the current task name from the branch name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'summary' -d 'Get a summary of current GIT repository branch, SHA and dirty status.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'commit_with_task' -d 'Commit changes including the task name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'ct' -d 'Commit changes including the task name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'commit_all_with_task' -d 'Commit all changes including the task name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'cat' -d 'Commit all changes including the task name.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "commit_all_with_task"' -s a -l add-all   -d 'Add all files before commiting.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "cat"' -s a -l add-all   -d 'Add all files before commiting.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'reset' -d 'Reset all uncommitted changes.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'cleanup' -d 'Deletes all non default branches.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'delete' -d 'Deletes one or more branch both locally and on a remote.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'd' -d 'Deletes one or more branch both locally and on a remote.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "delete"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "d"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'start' -d 'Starts a new branch out of the base one.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 's' -d 'Starts a new branch out of the base one.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "start"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "s"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'refresh' -d 'Rebases the current branch on top of an existing remote branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'r' -d 'Rebases the current branch on top of an existing remote branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "refresh"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "r"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'finish' -d 'Merges a branch back to its base remote branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'f' -d 'Merges a branch back to its base remote branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "finish"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "f"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'full_finish' -d 'Merges a branch back to its base remote branch and then deletes the local copy.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'ff' -d 'Merges a branch back to its base remote branch and then deletes the local copy.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "full_finish"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "ff"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'fast_commit' -d 'Creates a local branch, commit changes and then merges it back to the base branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'fc' -d 'Creates a local branch, commit changes and then merges it back to the base branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "fast_commit"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "fc"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'pull_request' -d 'Sends a Pull Request and deletes the local branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'pr' -d 'Sends a Pull Request and deletes the local branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "pull_request"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "pr"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'fast_pull_request' -d 'Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'fpr' -d 'Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "fast_pull_request"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "fpr"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'release' -d 'Tags and pushes a new release branch out of the base one.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'rt' -d 'Tags and pushes a new release branch out of the base one.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rt"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rt"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'import' -d 'Imports latest changes to a local branch on top of an existing remote branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'i' -d 'Imports latest changes to a local branch on top of an existing remote branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "import"' -s t -l temporary -r  -d 'Name of the temporary branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "i"' -s t -l temporary -r  -d 'Name of the temporary branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "import"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "i"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'start_from_release' -d 'Starts a new branch out of a remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'rs' -d 'Starts a new branch out of a remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "start_from_release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rs"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "start_from_release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rs"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'refresh_from_release' -d 'Rebases the current branch on top of an existing remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'rr' -d 'Rebases the current branch on top of an existing remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "refresh_from_release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rr"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "refresh_from_release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rr"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'finish_to_release' -d 'Merges a branch back to its base remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'rf' -d 'Merges a branch back to its base remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "finish_to_release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rf"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "finish_to_release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rf"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'full_finish_to_release' -d 'Merges a branch back to its base remote release branch and then deletes the local copy.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'rff' -d 'Merges a branch back to its base remote release branch and then deletes the local copy.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "full_finish_to_release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rff"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "full_finish_to_release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rff"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'import_release' -d 'Imports latest changes to a local branch on top of an existing remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'ri' -d 'Imports latest changes to a local branch on top of an existing remote release branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "import_release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "ri"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "import_release"' -s t -l temporary -r  -d 'Name of the temporary branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "ri"' -s t -l temporary -r  -d 'Name of the temporary branch.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "import_release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "ri"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'delete_release' -d 'Deletes a release branch locally and remotely.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_global' -a 'rd' -d 'Deletes a release branch locally and remotely.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "delete_release"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rd"' -s p -l prefix -r  -d 'The prefix to use.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "delete_release"' -s r -l remote -r  -d 'The remote to act on.'
complete -c r -c fishamnium_git -f -n '__fishamnium_git_completion_is_command "rd"' -s r -l remote -r  -d 'The remote to act on.'
