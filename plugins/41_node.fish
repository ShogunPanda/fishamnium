for a in (yq -r 'to_entries[] | "alias \(.key) \"\(.value)\""' ~/.config/fish/fishamnium/data/node-aliases.yml)
  eval $a
end