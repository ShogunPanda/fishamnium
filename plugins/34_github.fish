function gh_wait_last_action -d "Waits for the last action to finish"
  g_is_repository; or return

  gh run watch $(gh run list --json databaseId -q ".[0].databaseId")
end

function gh_pr_branch -d "Shows the branch of a PR"
  g_is_repository; or return
  gh pr view $argv[1] --json headRefName | yq .headRefName
end 

function gh_pr_approve -d "Approves a PR"
  g_is_repository; or return

  set pr $argv[1]
  set message $argv[2]

  if test -z "$pr"
    __fishamnium_print_error "You must provide a PR ID."
    return 1
  else if test -z "$message"
    set message "LGTM!"
  end

  gh pr review -a -b "$message" $pr
end 