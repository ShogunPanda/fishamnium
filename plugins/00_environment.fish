# ----- Internal functions -----

set -g FISHAMNIUM_HELPER "$HOME/.local/share/fishamnium/bin/fishamnium"

function __fishamnium_print_success
  printf "%s%s%s%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_SUCCESS" "$argv" "$FISHAMNIUM_COLOR_RESET"
  return 1
end

function __fishamnium_print_error
  printf "%s%s%s%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_ERROR" "$argv" "$FISHAMNIUM_COLOR_RESET"
  return 1
end

function __fishamnium_shell_environment
  if not test -x "$FISHAMNIUM_HELPER"
    echo "Fishamnium helper not found: $FISHAMNIUM_HELPER" >&2
    return 1
  end

  set -l output ($FISHAMNIUM_HELPER $argv)
  set -l code $status

  test $code -eq 0; or return $code
  test (count $output) -gt 0; and printf "%s\n" $output | source
end

function __fishamnium_find_configuration_file
  $FISHAMNIUM_HELPER configuration-file
end

function __fishamnium_get_configuration
  if test (count $argv) -gt 1
    $FISHAMNIUM_HELPER config "$argv[1]" "$argv[2]"
  else
    $FISHAMNIUM_HELPER config "$argv[1]"
  end
end

function __fishamnium_select
  set -l prompt "$argv[1]"

  $FISHAMNIUM_HELPER select --prompt "$prompt"
  return $pipestatus[1]
end

function __fishamnium_multiselect
  set -l prompt "$argv[1]"

  $FISHAMNIUM_HELPER select --prompt "$prompt" --multi
  return $pipestatus[1]
end

# ----- Public functions -----

function fishamnium_update_colors -d "Updates fishamnium color settings"
  set -l existing_path (string join : $PATH)

  if test -n "$argv[1]"
    __fishamnium_shell_environment shell-environment "$existing_path" "$argv[1]"
  else
    __fishamnium_shell_environment shell-environment "$existing_path"
  end

  set fish_color_normal $FISHAMNIUM_COLOR_FOREGROUND
  set fish_color_command $FISHAMNIUM_COLOR_FOREGROUND
  set fish_color_keyword $FISHAMNIUM_COLOR_FOREGROUND
  set fish_color_quote -o
  set fish_color_redirection -o $FISHAMNIUM_COLOR_PRIMARY
  set fish_color_error $FISHAMNIUM_COLOR_RED
  set fish_color_param $FISHAMNIUM_COLOR_CYAN
  set fish_color_valid_path $FISHAMNIUM_COLOR_CYAN
  set fish_color_comment $FISHAMNIUM_COLOR_GRAY
  set fish_color_operator $FISHAMNIUM_COLOR_PRIMARY
  set fish_color_escape $FISHAMNIUM_COLOR_PRIMARY
  set fish_color_autosuggestion $FISHAMNIUM_COLOR_GRAY
  set fish_color_cancel $FISHAMNIUM_COLOR_WHITE -b $FISHAMNIUM_COLOR_RED
  set fish_color_search_match $FISHAMNIUM_COLOR_CYAN
  set fish_color_history_current -o

  set fish_pager_color_progress -o -b $FISHAMNIUM_COLOR_GRAY
  set fish_pager_color_prefix -o $FISHAMNIUM_COLOR_FOREGROUND
  set fish_pager_color_completion -o $FISHAMNIUM_COLOR_CYAN
  set fish_pager_color_description -o $FISHAMNIUM_COLOR_GRAY
  set fish_pager_color_selected_background -b $FISHAMNIUM_COLOR_CYAN
  set fish_pager_color_selected_prefix -o $FISHAMNIUM_COLOR_WHITE
  set fish_pager_color_selected_completion $FISHAMNIUM_COLOR_WHITE
  set fish_pager_color_selected_description $FISHAMNIUM_COLOR_LIGHTGRAY
end

function fishamnium_reload -d "Reloads Fishamnium"
  printf "%s%s--> Reloading Fishamnium ...%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$FISHAMNIUM_COLOR_RESET"
  $FISHAMNIUM_HELPER reload
  source ~/.config/fish/conf.d/fishamnium.fish
end

function fishamnium_forced_reload -d "Reloads Fishamnium (forced)"
  set -e -g FISHAMNIUM_PLUGINS FISHAMNIUM_COMPLETIONS FISHAMNIUM_LOADED_PLUGINS FISHAMNIUM_LOADED_COMPLETIONS
  fishamnium_reload
end

function fishamnium_update -d "Updates Fishamnium"
  rm -rf ~/.local/share/fishamnium ~/.config/fish/conf.d/fishamnium.fish
  curl -sSL https://sw.cowtech.it/fishamnium/installer | fish

  bookmarks_export_to_env
  fishamnium_forced_reload
end

function fish_user_key_bindings
  bind \e\[1\;5A history-token-search-backward
  bind \e\[1\;5B history-token-search-forward
  bind \e\[1\;5C forward-word
  bind \e\[1\;5D backward-word
  bind \eB backward-word
  bind \eF forward-word
end

# ----- Bash compatibility -----

function export
  for item in $argv
    set parts (string split -m 1 = -- $item)
    test (count $parts) -eq 2; and set -x -g $parts[1] $parts[2]
  end
end

# ----- Bootstrap -----

set -l __fishamnium_existing_path (string join : $PATH)
__fishamnium_shell_environment shell-environment "$__fishamnium_existing_path"

fish_config theme choose None
fishamnium_update_colors $FISHAMNIUM_COLOR_THEME
set -x -g fish_greeting

command -q direnv; and direnv hook fish | source
