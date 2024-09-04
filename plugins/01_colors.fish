function fishamnium_update_colors -d "Updates fishamnium color settings"
  set -f profile $argv[1]

  if test -z "$profile" -a "$(uname)" = "Darwin"
    set -f profile $(python3 ~/.config/fish/fishamnium/data/iterm2/get_default_profile.py)
  end

  set profile $(string lower "$profile")

  set -f WHITE FFFFFF
  set -f BLACK 000000
  set -f RED CC0000
  set -f GREEN 008800
  set -f LIGHTGREEN 00CC00
  set -f YELLOW FFDF00
  set -f MAGENTA C800E2
  set -f BLUE 005be4
  set -f GRAY 808080

  if test "$profile" = "light"
    set -f RED CC0000
    set -f CYAN 0088E2
    set -f FOREGROUND $BLACK
    set -f PRIMARY $MAGENTA
    set -f SECONDARY $CYAN
  else
    set -f RED EE0000
    set -f CYAN 5EBBF9
    set -f FOREGROUND $WHITE
    set -f PRIMARY $YELLOW
    set -f SECONDARY $CYAN
  end

  fish_config theme choose None

  set -x -g FISHAMNIUM_COLOR_PROFILE $profile
  set -x -g FISHAMNIUM_COLOR_RESET $(set_color normal)
  set -x -g FISHAMNIUM_COLOR_BOLD $(set_color -o)
  set -x -g FISHAMNIUM_COLOR_NORMAL "\x1b[22m"
  set -x -g FISHAMNIUM_COLOR_ERROR $(set_color $RED)
  set -x -g FISHAMNIUM_COLOR_SUCCESS $(set_color $GREEN)
  set -x -g FISHAMNIUM_COLOR_PRIMARY $(set_color $PRIMARY)
  set -x -g FISHAMNIUM_COLOR_SECONDARY $(set_color $SECONDARY)
  set -x -g FISHAMNIUM_INTERACTIVE_COLORS "prompt:3:bold,bg+:-1,fg+:2:bold,pointer:2:bold,hl:-1:underline,hl+:2:bold:underline"

  set fish_color_normal $FOREGROUND
  set fish_color_command $FOREGROUND
  set fish_color_keyword $FOREGROUND
  set fish_color_quote -o
  set fish_color_redirection -o $PRIMARY
  set fish_color_error $RED
  set fish_color_param $CYAN
  set fish_color_valid_path $CYAN
  set fish_color_comment $GRAY
  set fish_color_operator $PRIMARY
  set fish_color_escape $PRIMARY
  set fish_color_autosuggestion $GRAY
  set fish_color_cancel $WHITE -b $RED
  set fish_color_search_match $CYAN
  set fish_color_history_current -o

  set fish_pager_color_progress -o -b $GRAY
  set fish_pager_color_prefix -o $FOREGROUND
  set fish_pager_color_completion -o $CYAN
  set fish_pager_color_description -o $GRAY
  set fish_pager_color_selected_background -b $CYAN
  set fish_pager_color_selected_prefix -o $WHITE
  set fish_pager_color_selected_completion $WHITE
  set fish_pager_color_selected_description $GRAY
end

# The environment variable is sent to inherit in SSH
fishamnium_update_colors $FISHAMNIUM_COLOR_PROFILE