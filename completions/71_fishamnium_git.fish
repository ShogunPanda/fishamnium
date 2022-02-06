#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

function __fishamnium_git_branches
  command git branch --no-color | string trim -c ' *' | string replace -r ".+" "\$0\tGIT Branch"
end

# Global flags
set _facRemoteArg "((-r|--remote)\\s+\\S+)"
set _facGlobalArgs "(\\s+(-q|-n|--quiet|--dry-run|$_facRemoteArg))*"
set _facEnd "\\s+\\S*"

# Specific args
set _facBranchArg "(\\s+[^-]\\S*)"
set _facMessageArg "(\\s+\\S.+)"
set _facForceArg "(\\s+(-f|--force))*"
set _facPrefixArg "(\\s+(-p|--prefix)\\s+\\S+)*"
set _facTemporaryArg "(\\s+(-t|--temporay)\\s+\\S+)*"

for i in g fishamnium
  complete -f -c $i -n "__fishamnium_complete 'git.*'" -s q -l quiet -d "Be more quiet"
  complete -f -c $i -n "__fishamnium_complete 'git.*'" -s n -l dry-run -d "Do not execute write action"
  complete -f -c $i -n "__fishamnium_complete 'git.*'" -s F -l no-verify -d "Do not execute commit or push related hooks"
  complete -x -c $i -n "__fishamnium_complete 'git.*'" -s r -l remote -d "The remote to act on" -a "(fishamnium git remotes --autocomplete)"

  # All the commands below are grouped by similar arguments
  # Commands
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs$_facEnd'" -a "(fishamnium git autocomplete)"

  # Read commands
  complete -f -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(remotes|lr)$_facEnd'" -s a -l autocomplete -d "Only list remotes name and description for autocompletion"

  # Write and workflow commands
    # Write
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(push|p)$_facGlobalArgs$_facForceArg$_facGlobalArgs$_facEnd'" -a "(__fishamnium_git_branches)"
  complete -f -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(push|p)(\\s\\S+)*$_facEnd'" -s f -l force -d "Perform a forced push."

  complete -f -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(delete|d)$_facGlobalArgs($_facEnd)+'" -a "(__fishamnium_git_branches)"

  complete -f -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(update|u)$_facGlobalArgs$_facEnd'" -a "(__fishamnium_git_branches)"

    # Workflow
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(start|release|s|rt)$_facGlobalArgs$_facBranchArg$_facEnd'" -a "(__fishamnium_git_branches)"

  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(refresh|finish|full_finish|pull_request|r|f|ff|pr)$_facGlobalArgs$_facEnd'" -a "(__fishamnium_git_branches)"

  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(fast_commit|fast_pull_request|fc|pr)$_facGlobalArgs$_facBranchArg$_facMessageArg$_facEnd'" -a "(__fishamnium_git_branches)"

  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(import|i)$_facGlobalArgs$_facTemporaryArg$_facGlobalArgs($_facBranchArg{0,1})$_facEnd'" -a "(__fishamnium_git_branches)"
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(import|i)$_facGlobalArgs$_facEnd'" -s t -l temporary -d "Name of the temporary branch."

    # Workflow release
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(start_from_release|rs)$_facGlobalArgs$_facPrefixArg$_facGlobalArgs$_facBranchArg$_facEnd'" -a "(__fishamnium_git_branches)"
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(start_from_release|rs)$_facGlobalArgs$_facEnd'" -s p -l prefix -d "The prefix to use."

  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(refresh_from_release|finish_to_release|full_finish_to_release|pull_request|rr|rf|rff)$_facGlobalArgs$_facPrefixArg$_facGlobalArgs$_facEnd'" -a "(__fishamnium_git_branches)"
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(refresh_from_release|finish_to_release|full_finish_to_release|pull_request|rr|rf|rff)$_facGlobalArgs$_facEnd'" -s p -l prefix -d "The prefix to use."

  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(import_to_release|ri)$_facGlobalArgs($_facTemporaryArg|$_facPrefixArg){0,2}$_facGlobalArgs$_facBranchArg$_facEnd'" -a "(__fishamnium_git_branches)"
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(import_to_release|ri)$_facGlobalArgs$_facPrefixArg$_facEnd'" -s t -l temporary -d "Name of the temporary branch."
  complete -x -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(import_to_release|ri)$_facGlobalArgs$_facTemporaryArg$_facEnd'" -s p -l prefix -d "The prefix to use."

  complete -f -c $i -n "__fishamnium_complete 'git$_facGlobalArgs\\s+(delete_release|rd)$_facGlobalArgs$_facEnd'" -s p -l prefix -d "The prefix to use."
end
