# Coalesces:
# - plugins/00_boot.fish
# - plugins/01_colors.fish
# - plugins/02_logging.fish
# - plugins/10_environment.fish
# - plugins/11_compatibility.fish
# - plugins/12_configuration.fish

# Internal functions
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
  $FISHAMNIUM_HELPER config "$argv[1]" "$argv[2]"
end

# Public functions
function fishamnium_update_colors -d "Updates fishamnium color settings"
  if test -n "$argv[1]"
    __fishamnium_shell_environment shell-environment (string join : $PATH) "$argv[1]"
  else
    __fishamnium_shell_environment shell-environment (string join : $PATH)
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
  $FISHAMNIUM_HELPER exit
  source ~/.config/fish/conf.d/fishamnium.fish
end

function fishamnium_forced_reload -d "Reloads Fishamnium (forced)"
  set -e -g FISHAMNIUM_PLUGINS FISHAMNIUM_COMPLETIONS FISHAMNIUM_LOADED_PLUGINS FISHAMNIUM_LOADED_COMPLETIONS
  fishamnium_reload
end

function fishamnium_update -d "Updates Fishamnium"
  rm -rf ~/.local/share/fishamnium ~/.config/fish/conf.d/fishamnium.fish
  curl -sL https://sw.cowtech.it/fishamnium/installer | fish

  bookmarks_export_to_env
  fishamnium_forced_reload
end

# Bash compatibility
function export
  set command $(echo $argv | tr '=' ' ')
  eval "set -x -g $command"
end

# Basic environment
__fishamnium_shell_environment shell-environment (string join : $PATH)

# The environment variable is sent to inherit in SSH.
fishamnium_update_colors $FISHAMNIUM_COLOR_PROFILE

set -x -g EDITOR "nvim"
set -x -g GEDITOR "code"
set -x -g fish_greeting

# Direnv
which direnv > /dev/null
test $status -eq 0; and direnv hook fish | source
