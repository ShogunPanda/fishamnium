function gh_wait_last_action
  gh run watch (gh run list --json databaseId -q ".[0].databaseId")
end