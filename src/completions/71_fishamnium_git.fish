#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fishamnium_git_verify
  set cmd (commandline -opc)
  ~/.fishamnium/helpers/fishamnium autocomplete $argv -- $cmd
  return $status
end

complete -c fishamnium -e
complete -c b -e
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify bookmarks#b" -f -a "read get show load r g" -d "Reads a bookmark"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify bookmarks#b" -f -a "write set save store w s" -d "Writes a bookmark"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify bookmarks#b" -f -a "delete erase remove d e" -d "Deletes a bookmark"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify bookmarks#b" -f -a "list all l a" -d "Lists all bookmarks"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify bookmarks#b list#all#l#a" -f -s n -l names-only -d "Only list bookmarks names"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify bookmarks#b list#all#l#a" -f -s a -l autocomplete -d "Only list bookmarks name and description for autocompletion"

complete -c g -e
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -s q -l quiet -d "Be more quiet."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -s n -l dry-run -d "Do not execute write action."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "is_repository ir" -d "Check if the current directory is a GIT repository."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "is_dirty id" -d "Check if the current GIT repository has uncommitted changes."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "remotes lr" -d "Show GIT remotes."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g remotes#lr" -f -s a -l autocomplete -d "Format for autocompletion."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "full_branch_name fbn" -d "Get the full current branch name."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "branch_name bn" -d "Get the current branch name."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "full_sha" -d "Get the full current GIT SHA."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "sha" -d "Get the current GIT SHA."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "summary ls" -d "Get a summary of current GIT repository branch, SHA and dirty status."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "task t" -d "Get the current task name from the branch name."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "commit_with_task ct" -d "Commit changes including the task name."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "commit_all_with_task cat" -d "Commit all changes including the task name."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g commit_all_with_task#cat" -f -s a -l add-all -d "Add all files before commiting."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "reset re" -d "Reset all uncommitted changes."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "cleanup cl" -d "Deletes all non default branches."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "update u" -d "Fetch from remote and pulls a a branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g update#u" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "push p" -d "Pushes the current branch to the remote."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g push#p" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g push#p" -f -s f -l force -d "If to perform a force push."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "delete d" -d "Deletes one or more branch both locally and on a remote."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g delete#d" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "start s" -d "Starts a new branch out of the base one."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g start#s" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "refresh r" -d "Rebases the current branch on top of an existing remote branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g refresh#r" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "finish f" -d "Merges a branch back to its base remote branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g finish#f" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "full_finish ff" -d "Merges a branch back to its base remote branch and then deletes the local copy."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g full_finish#ff" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "fast_commit fc" -d "Creates a local branch, commit changes and then merges it back to the base branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g fast_commit#fc" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "pull_request pr" -d "Sends a Pull Request and deletes the local branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g pull_request#pr" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "fast_pull_request fpr" -d "Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g fast_pull_request#fpr" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "release rt" -d "Tags and pushes a new release branch out of the base one."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g release#rt" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g release#rt" -x -s p -l prefix -d "The prefix to use."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "import i" -d "Imports latest changes to a local branch on top of an existing remote branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g import#i" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g import#i" -x -s t -l temporary -d "Name of the temporary branch."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "start_from_release rs" -d "Starts a new branch out of a remote release branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g start_from_release#rs" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g start_from_release#rs" -x -s p -l prefix -d "The prefix to use."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "refresh_from_release rr" -d "Rebases the current branch on top of an existing remote release branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g refresh_from_release#rr" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g refresh_from_release#rr" -x -s p -l prefix -d "The prefix to use."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "finish_to_release rf" -d "Merges a branch back to its base remote release branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g finish_to_release#rf" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g finish_to_release#rf" -x -s p -l prefix -d "The prefix to use."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "full_finish_to_release rff" -d "Merges a branch back to its base remote release branch and then deletes the local copy."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g full_finish_to_release#rff" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g full_finish_to_release#rff" -x -s p -l prefix -d "The prefix to use."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "import_release ri" -d "Imports latest changes to a local branch on top of an existing remote release branch."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g import_release#ri" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g import_release#ri" -x -s p -l prefix -d "The prefix to use."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g import_release#ri" -x -s t -l temporary -d "Name of the temporary branch."
ATG:complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g" -f -a "delete_release rd" -d "Deletes a release branch locally and remotely."
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g delete_release#rd" -x -s r -l remote -d "The remote to act on." -a "(fishamnium g lr -a)"
complete -c g -c fishamnium -n "__fishamnium_autocomplete_verify git#g delete_release#rd" -x -s p -l prefix -d "The prefix to use."

