test -x $HOME/.fishamnium_profile; and . $HOME/.fishamnium_profile

for i in $HOME/.fishamnium.d/*.fish;
  test -x $i; and . $i
end

for i in $HOME/.config/fishamnium/*.fish
  test -x $i; and . $i
end