#!/usr/bin/env fish

set output (git status -s 2>/dev/null)

if test -n "$output"
  echo -e "\x1b[31m------- Before triggering the workflow, make sure that the GIT branch is clean and pushed. -------\x1b[0m"
  exit 1
end

# TODO: Once cambi is released, use it to dump version and update CHANGELOG.md automatically rather than fetching from the loader
cat loader.fish | string match -qr -- "set -x -g FISHAMNIUM_VERSION \"(?<fishamniumVersion>[\d\.]+)\""

gh release create v$fishamniumVersion --generate-notes