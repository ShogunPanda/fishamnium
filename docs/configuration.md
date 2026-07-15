# Configuration

Fishamnium reads YAML from `~/.config/fishamnium/config.yml`. If `~/.config/fishamnium/config.<hostname>.yml` exists, it replaces the default file for that host; the two files are not merged. The hostname is truncated at the first dot.

Missing files and omitted properties use built-in defaults. Print the selected path with:

```fish
fishamnium configuration-file
```

## Example

```yaml
env:
  FOO: bar

hosts:
  example: example.com:2222

git:
  branch: main
  remote: origin
  root: ~/development
  upstreamRemote: upstream
  approvalMessage: LGTM!

bookmarksExportPrefix: B_
bookmarks:
  fishamnium:
    path: ~/development/fishamnium
    name: Fishamnium
  workspaces:
    path: ~/development
    name: Workspaces
    recursive: workspace

node:
  runner: npm

editor:
  terminal: nvim
  graphical: code

theme: dark
prompt: default
prompt_narrow: xsmall
prompt_narrow_threshold: 100
```

## Settings

| Setting | Default | Purpose |
| --- | --- | --- |
| `env` | `{}` | String-valued environment variables exported when Fishamnium loads |
| `hosts` | `{}` | Named host values available through `fishamnium config .hosts` |
| `git.branch` | `main` | Default base branch used by Git workflows |
| `git.remote` | `origin` | Default writable Git remote |
| `git.root` | `~/development` | Configured Git workspace root |
| `git.upstreamRemote` | `upstream` | Source remote used by `g_sync` |
| `git.approvalMessage` | `LGTM!` | Default body used by `gh_pr_approve` |
| `bookmarksExportPrefix` | `B_` | Prefix for bookmark environment variables |
| `bookmarks` | `{}` | Saved and recursive bookmark definitions |
| `node.runner` | `npm` | Package runner used by `nrc` and `nic` |
| `editor.terminal` | `nvim` | Exported as `EDITOR` |
| `editor.graphical` | `code` | Exported as `GEDITOR` |
| `theme` | `dark` | Shell color palette, either `light` or `dark` |
| `prompt` | `default` | Normal prompt theme |
| `prompt_narrow` | `xsmall` | Prompt theme below the width threshold |
| `prompt_narrow_threshold` | `100` | Terminal width at which the narrow prompt is selected |
| `colors` | bundled palette | Light and dark shell color palettes |
| `prompts` | bundled themes | Additional or replacement prompt themes |
| `prompt_overrides` | `{}` | Overrides applied to the selected prompt theme |

All `env` values must be YAML strings. Quote numbers and booleans when they should be exported, for example `ANSWER: "42"`.

## Bookmarks

A regular bookmark has a path and display name:

```yaml
bookmarks:
  docs:
    path: ~/Documents
    name: Documents
```

Adding `recursive` creates a `<recursive>-root` bookmark and one `<recursive>-<directory>` bookmark for each visible child directory:

```yaml
bookmarks:
  projects:
    path: ~/development
    name: Projects
    recursive: project
```

`bookmark_save` and `bookmark_delete` update the selected configuration file atomically. Bookmark IDs may contain letters, numbers, `-`, `_`, `.`, `:`, and `@`.

## Colors

`colors.light` and `colors.dark` accept the keys `white`, `black`, `lightgreen`, `yellow`, `magenta`, `blue`, `gray`, `lightgray`, `orange`, `red`, `green`, `cyan`, `foreground`, `primary`, and `secondary`. Values are six-digit RGB hex strings without `#`.

The selected palette configures Fish syntax colors and exports `FISHAMNIUM_COLOR_*`, `FISHAMNIUM_COLOR_FG_*`, and `FISHAMNIUM_COLOR_BG_*` variables for plugin output.

## Prompt themes

Bundled prompt names are `xsmall`, `small`, `medium`, `default`, `large`, and `xlarge`. A custom theme can define colors, reusable styles, and a single or multiline template:

```yaml
prompts:
  compact:
    colors:
      user:
        regular: "008800"
        root: "cc0000"
      host: "ffdf00"
      path: "0088e2"
      time: "013482"
    styles:
      warning: "bold hex:ff0000"
    template: "<bold user> {user}@{host} {path} {git_status}> "

prompt: compact
```

Available variables are `{user}`, `{host}`, `{path}`, `{full_path}`, `{git_branch}`, `{git_hash}`, `{git_status}`, `{time}`, `{date_time}`, `{node}`, `{rust}`, `{ruby}`, and `{go}`. Wrap application-only content in `{app:...}`; it is emitted only when a Node.js, Rust, Ruby, or Go project is detected.

Color declarations generate `<name>`, `<name>_fg`, `<name>_bg`, and `<name>_text` styles. Templates also support `<bg_reset>` and `<fg_reset>`. `prompt_overrides` has the same `colors`, `styles`, and `template` fields and is applied to any selected theme.

## Reading values

`config` and `configuration` are equivalent. Selectors use dot notation, and an optional final argument is returned when the property is absent:

```fish
fishamnium config .git.branch
fishamnium config .node.runner pnpm
fishamnium config .hosts
fishamnium config format ~/.config/fishamnium/config.yml
```

Mappings are printed as tab-separated rows, sequences as space-separated values, and scalar values as text.

## Custom Fish files

Every executable `~/.config/fishamnium/*.fish` file is sourced after the standard utility plugins load. Use this directory for machine-local aliases, functions, and environment setup. See [Project hooks](plugins.md#project-hooks) for per-project customization.
