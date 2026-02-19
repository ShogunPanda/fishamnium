for a in (yq -r 'to_entries[] | "alias \(.key) \"\(.value)\""' ~/.local/share/fishamnium/data/node-aliases.yml)
  eval $a
end