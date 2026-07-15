# Helper

The native helper is installed as `~/.local/share/fishamnium/bin/fishamnium` and added to `PATH` as `fishamnium`. It renders the prompt, reads configuration, performs repository queries, provides interactive selection, and serves operations used by the Fish plugins.

Running a command normally boots a background helper server and sends the request to it. Commands that require direct terminal or process access, including `select`, `agents`, `git`, `node`, `prompt`, `ssh`, and `completions`, can run locally. Use `fishamnium reload` after changing configuration to restart the server.

## Invocation

```text
fishamnium [--server | --client IP:PORT] [COMMAND] [ARGUMENTS...]
```

| Option | Purpose |
| --- | --- |
| `--server` | Run only the helper server |
| `--client IP:PORT` | Send the command to a helper server at an explicit address |
| `reload` | Stop the existing server and boot a replacement |
| `exit`, `quit` | Terminate the helper server |
| `pid` | Print the server process ID |

## Environment and configuration

| Command | Output |
| --- | --- |
| `env [PATH]` | Shell-neutral `NAME="value"` environment assignments |
| `shell-environment [PATH] [light\|dark]` | Fish commands that export the environment and color palette |
| `colors [light\|dark]` | Fish commands that export color variables |
| `vscode-theme [light\|dark]` | VS Code terminal color JSON |
| `configuration-file` | Active host-specific or default configuration path |
| `config SELECTOR [FALLBACK]` | Configuration value selected with dot notation |
| `configuration SELECTOR [FALLBACK]` | Alias of `config` |
| `config format PATH` | Parse and rewrite a configuration as normalized YAML on stdout |
| `completions` | Generated Fish completions for the helper |

## Bookmarks

Most listing commands accept an optional regular expression matching bookmark IDs.

| Command | Purpose |
| --- | --- |
| `bookmarks list [REGEX]` | Render a table |
| `bookmarks list-raw [REGEX]` | Print ID, name, stored path, and expanded path as TSV |
| `bookmarks tsv [REGEX]` | Print ID, path, and name as TSV |
| `bookmarks vscode-projects [REGEX]` | Print VS Code Projects-compatible JSON |
| `bookmarks export [REGEX] [PREFIX]` | Print environment assignments |
| `bookmarks autocomplete [REGEX]` | Print ID and path completion rows |
| `bookmarks names [REGEX]` | Print bookmark IDs |
| `bookmarks show ID` | Print the expanded bookmark path |
| `bookmarks save ID [NAME]` | Save the current directory |
| `bookmarks delete ID` | Delete a configured bookmark |

## Git and Node.js

Git query commands discover the repository from the current directory.

| Command | Purpose |
| --- | --- |
| `git is-repository` | Succeed when inside a repository |
| `git branch-name` | Print the short current branch |
| `git full-branch-name` | Print the full ref name |
| `git sha` | Print the seven-character HEAD SHA |
| `git full-sha` | Print the full HEAD SHA |
| `git dirty` | Print `true` when tracked or untracked changes exist |
| `git branches` | Print local branches as selection rows |
| `git remotes` | Print remotes as JSON |
| `git remotes-list` | Print remote names as completion rows |
| `git remotes-autocomplete` | Print remote names and URLs as completion rows |
| `git remote-url NAME` | Print a remote fetch URL |
| `git worktrees [FOLDER]` | Print name, path, and branch as TSV |
| `node scripts [PACKAGE_JSON]` | Print sorted package script names |

## Interactive selection

`select` reads newline-, NUL-, or tab-separated rows from standard input. It searches all columns and prints the first column by default.

```fish
printf "one\tFirst choice\ntwo\tSecond choice\n" |
  fishamnium select --prompt "Choose an item"
```

| Option | Purpose |
| --- | --- |
| `--prompt TEXT` | Set the prompt text |
| `--multi` | Select multiple rows with Tab and confirm with Enter |
| `--raw` | Return the complete selected rows instead of their first columns |

Type to filter, use Up/Down or `j`/`k` to move, Enter to accept, and Escape or Ctrl-C to cancel.

## Prompt

```text
fishamnium prompt [--theme NAME] [--width COLUMNS] [--path PATH]
```

The loader also supplies `--status`, `--duration`, and the current terminal width. `--status`, `--pipestatus`, and `--duration` are accepted for compatibility but are not currently template variables. See [Prompt themes](configuration.md#prompt-themes) for template configuration.

## Agents, SSH, and tmux

| Command | Purpose |
| --- | --- |
| `agents opencode list [FOLDER]` | List top-level OpenCode sessions as ID, directory, and title TSV |
| `agents opencode last [FOLDER]` | Print the most recently updated OpenCode session ID |
| `ssh show` | Copy and print the current user, host, and directory as a marked location |
| `ssh available` | Succeed when the clipboard contains a marked SSH location |
| `ssh connect` | Connect to the marked host and directory, or start Fish when none is present |
| `tmux next-session` | Print the first unattached NATO-alphabet session name |

`ssh show` uses OSC 52 and supports `FISHAMNIUM_SSH_HOST` to override the advertised hostname. Clipboard reads support `pbpaste`, `wl-paste`, `xclip`, and `xsel`; clipboard clearing uses their corresponding writer.
