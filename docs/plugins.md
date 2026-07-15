# Plugins

Plugins are sourced in filename order from `~/.local/share/fishamnium/plugins`. The numeric prefixes establish dependencies: environment setup first, utility functions next, then Git, Node.js, and OpenCode integrations.

## Environment (`00_environment.fish`)

This plugin starts Fishamnium's shell environment, applies syntax and pager colors, clears the Fish greeting, installs key bindings, and loads `direnv hook fish` when `direnv` is available.

| Function | Purpose |
| --- | --- |
| `fishamnium_update_colors [THEME]` | Reload environment and Fish colors, optionally using `light` or `dark` |
| `fishamnium_reload` | Restart the helper and source the Fishamnium loader |
| `fishamnium_forced_reload` | Clear loaded-file caches and reload |
| `fishamnium_update` | Remove and reinstall Fishamnium, then regenerate bookmark exports |
| `export NAME=VALUE ...` | Bash-compatible environment assignment helper |

The plugin exports `FISHAMNIUM_HELPER`, environment paths, editor settings, prompt settings, configured `env` values, and the complete `FISHAMNIUM_COLOR_*` palette.

## Bookmarks (`20_bookmarks.fish`)

Bookmarks are stored in the active YAML configuration. On load, this plugin exports bookmarks to environment variables and writes VS Code project data to `~/.local/state/fishamnium/vscode-projects.json`.

| Function | Purpose |
| --- | --- |
| `bookmarks_list [-e] [-p PREFIX] [REGEX]` | List bookmarks or emit Fish export commands |
| `bookmarks_autocomplete [REGEX]` | Print completion rows |
| `bookmarks_names [REGEX]` | Print bookmark IDs |
| `bookmarks_vscode_projects [REGEX]` | Print VS Code Projects JSON |
| `bookmark_show [-y] ID` | Print a path; `-y` also copies it |
| `bookmark_cd [-s] ID` | Change directory; `-s` uses `pushd` |
| `bookmark_open ID` | Open with `GEDITOR` |
| `bookmark_edit ID` | Open with `EDITOR` |
| `bookmark_save ID [NAME]` | Save the current directory |
| `bookmark_delete ID` | Delete a bookmark |
| `bookmarks_export_to_env` | Regenerate the executable bookmark environment plugin |
| `bookmarks_export_to_vscode [REGEX]` | Regenerate the VS Code projects file |
| `bookmark_delete_select` | Interactively delete bookmarks |
| `bookmark_cd_select [-s]` | Interactively change directory |
| `bookmark_open_select` | Interactively open a bookmark |

Aliases: `l` list, `le` export, `b` show, `y` show and copy, `s` save, `d` delete, `c` change directory, `cs` push directory, `o` open, `e` edit, `ds` select deletion, `ci` select directory, `cis` select and push directory, and `os` select and open.

## Projects (`21_projects.fish`)

A project root is an ancestor containing `package.json`, `Makefile.toml`, `Cargo.toml`, `Makefile`, `go.mod`, or `README.md`.

| Function | Purpose |
| --- | --- |
| `project_root [-c] [-f] [-q] [-y]` | Find the nearest root; include current, fallback, quiet, or copy |
| `project_roots [-c] [-q] [-y]` | List all ancestor roots |
| `project_type [ROOT]` | Print `javascript`, `makers`, `rust`, `make`, or `shell` |
| `project_runner [ROOT]` | Print `npm`, `makers`, `cargo`, `make`, or `bash` |
| `cd_project_root [-N]` | Change to the root, or describe it with dry-run mode |
| `project_build [ROOT]` | Run the project-type build command |
| `project_test [ROOT]` | Run the project-type test command |
| `project_deploy` | Run the project-type deploy command; Rust is unsupported |

Aliases: `p`, `pmt`, `pmr`, `pb`, `pt`, `pd`, and `cdr` map to the functions above.

## Lists (`22_lists.fish`)

`execute_on_list` runs a command in multiple directories and restores the original directory after each item.

```fish
execute_on_list directories.txt git status
execute_on_list -l "/repo/one /repo/two" npm test
execute_on_list -x "bookmarks_names '^project-'" git pull
```

Use `-l` for a space-separated literal list, `-x` to evaluate a command that produces the list, and `-c` to continue after failures. Blank behavior follows Fish list expansion, and lines beginning with `#` are skipped. Alias: `eol`.

## General aliases (`23_aliases.fish`)

| Alias | Expansion |
| --- | --- |
| `clcd` | `clear; cd` |
| `clf` | Reset the terminal with `printf "\033c"` |
| `cdc` | Change to the physical current directory |
| `cdf` | `pushd` |
| `cdb`, `cdl` | `popd` |
| `cdy` | Copy the current directory |
| `cdn` | Print the current directory name |
| `cp` | `cp -R -v -i` |
| `mv` | `mv -v -i` |
| `rm` | `rm -R` |
| `ls` | `/bin/ls -h -F` |
| `sudo` | `sudo -H` |
| `eol` | `execute_on_list` |

## User customs (`24_user_customs.fish`)

This plugin sources executable `~/.config/fishamnium/*.fish` files and implements project directory hooks.

### Project hooks

An executable `.fishamnium.fish` in a project root is sourced when entering or leaving that project. During execution, these helpers are available:

| Function | Purpose |
| --- | --- |
| `fishamnium_dirhook_operation` | Print `enter` or `leave` |
| `fishamnium_dirhook_project_current` | Print the root being entered or left |
| `fishamnium_dirhook_project_other` | Print the other root during a direct project transition |
| `fishamnium_dirhook_is_enter` | Succeed while entering |
| `fishamnium_dirhook_is_leave` | Succeed while leaving |
| `fishamnium_dirhook_project_path PATH...` | Join paths to the current project root |
| `fishamnium_dirhook_export NAME VALUE...` | Export on enter and erase on leave |
| `fishamnium_dirhook_alias NAME COMMAND...` | Create an alias on enter and erase it on leave |

```fish
#!/usr/bin/env fish

fishamnium_dirhook_export NODE_ENV development
fishamnium_dirhook_alias serve npm run dev

if fishamnium_dirhook_is_enter
  set -gx PROJECT_CONFIG (fishamnium_dirhook_project_path config local.yml)
else if fishamnium_dirhook_is_leave
  set -e PROJECT_CONFIG
end
```

The context variables are temporary and should be accessed through the helper functions.

## Git (`30_git.fish`)

The Git plugin provides repository queries, guarded write operations, interactive branch and worktree selection, GitHub helpers, and higher-level workflows. Most write functions support `-N` for a dry run; remote-aware functions support `-r REMOTE`.

| Function | Purpose |
| --- | --- |
| `g_default_branch`, `g_default_remote` | Print configured defaults, honoring `GIT_DEFAULT_BRANCH` and `GIT_DEFAULT_REMOTE` |
| `g_is_repository`, `g_is_dirty`, `g_summary` | Inspect repository state |
| `g_remotes`, `g_remotes_autocomplete` | Print remote details |
| `g_branch_name`, `g_full_branch_name` | Print the current branch |
| `g_sha`, `g_full_sha` | Print the current commit |
| `g_pull_request_url [BASE] [BRANCH]` | Find an existing GitHub pull request URL |
| `g_push`, `g_update`, `g_reset`, `g_delete`, `g_cleanup` | Push, update, reset, delete, or clean branches |
| `g_switch`, `g_branch_delete_select` | Interactively switch or delete branches |
| `g_worktree_cd_select`, `g_worktree_delete_select` | Interactively enter or delete worktrees |
| `g_start BRANCH [BASE]` | Update the base branch and create a branch |
| `g_refresh [-m] [BASE]` | Rebase, or merge with `-m`, the current branch on the updated base |
| `g_pull_request [BASE]` | Refresh, push, open a PR URL, return to base, and delete the local branch |
| `g_fast_pull_request BRANCH MESSAGE [BASE]` | Create, commit, refresh, and send a pull request |
| `g_sync [BRANCH]` | Pull from the upstream remote and force-push to the writable remote |
| `gh_pr_branch PR`, `gh_pr_approve PR [MESSAGE]` | Read or approve a GitHub pull request |
| `gh_remote_add OWNER/REPO [NAME]` | Add an SSH GitHub remote |

`g_pull_request` and `g_fast_pull_request` also accept `-f` to force push and `-s` to skip Git hooks. Commands that delete branches, reset changes, force-push, or clean files are intentionally destructive; use `-N` where available before running them.

## Git aliases (`31_git_aliases.fish`)

The plugin includes these direct Git aliases:

| Area | Aliases |
| --- | --- |
| Status and diff | `gst`, `gss`, `gsd` |
| Pull | `gl`, `glr` |
| Commit | `gc`, `gcs`, `gcn`, `gcns`, `gce`, `gces`, `gcen`, `gcens`, `gca`, `gcas`, `gcan`, `gcans`, `gcae`, `gcaes`, `gcaen`, `gcaens`, `gcf`, `gcfs`, `gcaf`, `gcafs`, `gcw`, `gcws`, `gcaw`, `gcaws` |
| Checkout | `gco`, `gcot`, `gcom`, `gcob` |
| Remotes | `gr`, `grv`, `grmv`, `grrm`, `grset`, `grup` |
| Rebase | `grbi`, `grbc`, `grba`, `grbs` |
| Cherry-pick | `gcp`, `gcpc`, `gcpa`, `gcps` |
| Branch | `gb`, `gbc`, `gba`, `gbd`, `gbm` |
| Config and log | `gcl`, `glo`, `glog` |
| Add and merge | `ga`, `gaa`, `gme`, `gmt`, `gmf` |
| Reset and find | `grh`, `grhh`, `gf` |
| Worktrees | `gtl`, `gta`, `gtd`, `gtp` |

Function aliases are `gir`, `gis`, `gls`, `glr`, `glra`, `gbn`, `gfbn`, `gi`, `gfi`, `gpru`, `gbs`, `gbds`, `gp`, `gpf`, `gu`, `gre`, `grd`, `grc`, `gws`, `gwr`, `gwrm`, `gwpr`, `gwfpr`, `gwy`, `gts`, and `gtds`. GitHub CLI aliases are `gho`, `ghpr`, `ghprb`, `ghpra`, `ghprm`, and `ghra`.

## Node.js (`40_node.fish`)

This plugin prepends `./node_modules/.bin` to `PATH`.

| Function | Purpose |
| --- | --- |
| `nrc` | Select and run a `package.json` script with the configured runner |
| `nic` | Remove `node_modules` and lockfiles, then reinstall with the configured runner |
| `pnrc` | Run `nrc` with pnpm |
| `pnic` | Run `nic` with pnpm |

Node test aliases are `nt`, `ntt`, `nt1`, `ntt1`, `nto`, `ntot`, `nto1`, and `ntot1`. npm aliases are `ni`, `nid`, `nr`, `nrt`, `nrb`, `nre`, `nrs`, `nrv`, `nrf`, `nrl`, `nrd`, `no`, and `nu`. pnpm aliases are `pni`, `pna`, `pnad`, `pnr`, `pnrt`, `pnrb`, `pnre`, `pnrs`, `pnrv`, `pnrf`, `pnrl`, `pnrd`, `pno`, and `pnu`.

`nic` and `pnic` delete `node_modules`, `package-lock.json`, `pnpm-lock.yaml`, and `yarn.lock` before installing.

## OpenCode (`50_opencode.fish`)

This optional plugin integrates with the OpenCode CLI and its local session database.

| Function | Purpose |
| --- | --- |
| `opencode_attach` | Attach to `localhost:$FISHAMNIUM_OPENCODE_SERVER_PORT`, or run OpenCode normally |
| `opencode_session_open_select [-a]` | Select a session, enter its directory, and open or attach to it |
| `opencode_session_delete_select [-g]` | Select sessions to delete in the current directory or globally |
| `opencode_session_delete_last [-g]` | Delete the last current-directory or global session |
| `opencode_session_temporary [-a]` | Run or attach to OpenCode and delete its last session on exit |

Aliases: `oc`, `occ`, `ocs`, `ocss`, `oct`, `oca`, `ocac`, `ocas`, `ocass`, `ocat`, `ocl`, `ocd`, `ocdl`, `ocdlg`, `ocds`, and `ocdg`.

## Completions

The bundled completion files cover the environment functions, bookmarks, Git queries and workflows, and the helper CLI. Like plugins, only executable `.fish` files are sourced. The helper's own completion definition is generated by `fishamnium completions` during environment setup.
