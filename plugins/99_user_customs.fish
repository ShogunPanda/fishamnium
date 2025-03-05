test -x $HOME/.fishamnium_profile; and . $HOME/.fishamnium_profile

for i in $HOME/.fishamnium.d/*.fish $HOME/.config/fishamnium/*.fish;

  #test -x $i; and . $i
  if test -x $source
    echo $i;    
    source $source
  end
end