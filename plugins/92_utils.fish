function execute_on_list
  set orig_pwd $PWD

  for i in (cat $argv[1])
    echo "--- $i ---"
    cd $i
    eval $argv[2..]
    cd $orig_pwd
  end
end