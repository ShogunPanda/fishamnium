set -l base "node --test"
set -l only "" "--test-only"
set -l tap "" "--test-reporter=tap"
set -l concurrency "" "--test-concurrency=1"

set -e FISHAMNIUM_NODE_TEST_ALIASES

for o in $only
  for t in $tap
    for c in $concurrency
      set name nt

      if test "$o" = "--test-only"
        set name $name o
      end

      if test "$t" = "--test-reporter=tap"
        set name $name t
      end

      if test "$c" = "--test-concurrency=1"
        set name $name 1
      end

      set name (string join "" $name)
      set cmd (echo "$o $t $c" | string replace -a -r "\s+" " " | string trim)

      if test "$cmd" = ""
        continue
      end

      alias $name="$base $cmd"
      set FISHAMNIUM_NODE_TEST_ALIASES $FISHAMNIUM_NODE_TEST_ALIASES $name $cmd
    end
  end
end

