function switch_iterm2_profile
  set profile $argv[1]

  if test -z "$profile"
    set current_profile $(python3 ~/.local/share/fishamnium/data/iterm2/get_default_profile.py)
    if test "$current_profile" = "Dark"
      set profile "Light"
    else
      set profile "Dark"
    end
  end

  echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_PRIMARY--> Switching to profile $FISHAMNIUM_COLOR_BOLD$profile ...$FISHAMNIUM_COLOR_RESET"
  fishamnium_update_colors (string lower "$profile")
  python3 ~/.local/share/fishamnium/data/iterm2/switch_to_profile.py $profile    
end
