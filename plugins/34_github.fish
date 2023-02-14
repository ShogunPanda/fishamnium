function gh_wait_last_action -d "Waits for the last action to finish"
  g_is_repository; or return

  gh run watch $(gh run list --json databaseId -q ".[0].databaseId")
end

function gh_pr_branch -d "Shows the branch of a PR"
  g_is_repository; or return
  
  gh pr view $1 --json headRefName | yq .headRefName
end 
