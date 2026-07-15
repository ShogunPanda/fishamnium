# Fishamnium documentation

Fishamnium is loaded by Fish from `~/.config/fish/conf.d/fishamnium.fish`. The loader starts the helper, sources every executable file in `~/.local/share/fishamnium/plugins` and `~/.local/share/fishamnium/completions` in filename order, and installs the Fishamnium prompt.

## Guides

- [Configuration](configuration.md) describes the YAML configuration, host-specific files, colors, prompts, bookmarks, and custom environment variables.
- [Helper](helper.md) documents the `fishamnium` binary and its command-line interface.
- [Plugins](plugins.md) documents every bundled Fish plugin, its public functions, aliases, and optional dependencies.

## Installed files

| Path | Purpose |
| --- | --- |
| `~/.config/fish/conf.d/fishamnium.fish` | Loader sourced automatically by Fish |
| `~/.config/fishamnium/config.yml` | Default user configuration |
| `~/.config/fishamnium/config.<hostname>.yml` | Optional host-specific configuration |
| `~/.config/fishamnium/*.fish` | User customization scripts |
| `~/.local/share/fishamnium/bin/fishamnium` | Native helper binary |
| `~/.local/share/fishamnium/plugins` | Bundled and generated plugins |
| `~/.local/share/fishamnium/completions` | Fish completion definitions |
| `~/.local/state/fishamnium` | Runtime state, including the helper PID and exported VS Code projects |

Only executable plugin and completion files are sourced. To disable a bundled item without deleting it, remove its executable bit and run `fishamnium_forced_reload`.

## Common operations

```fish
# Reload plugins, completions, configuration, and the helper.
fishamnium_reload

# Clear the cached plugin lists before reloading.
fishamnium_forced_reload

# Reinstall the latest release.
fishamnium_update

# Show the active configuration file.
fishamnium configuration-file
```

The loader exports `FISHAMNIUM_LOADED_PLUGINS` and `FISHAMNIUM_LOADED_COMPLETIONS` with the filenames loaded in the current shell.
