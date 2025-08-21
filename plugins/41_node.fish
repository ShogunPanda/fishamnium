alias nt="node --test"
alias ntt="node --test --test-reporter=tap"
alias nto="node --test --test-only"
alias ntot="node --test --test-only --test-reporter=tap"

function ntow
  NODE_OPTIONS="--test --test-only" wtfnode $argv
end