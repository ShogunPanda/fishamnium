function execute_on_list
  set orig_pwd $PWD

  for item in (cat $argv[1])
    string match -qr -- "^#" "$item"; and continue;

    echo "--- $item ---"
    cd $item
    eval $argv[2..]
    cd $orig_pwd
  end
end