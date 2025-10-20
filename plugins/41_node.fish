alias nt="node --test"
alias nt1="node --test --test-concurrency=1"
alias ntt="node --test --test-reporter=tap"
alias ntt1="node --test --test-concurrency=1 --test-reporter=tap"
alias nto="node --test --test-only"
alias nto1="node --test --test-concurrency=1 --test-only"
alias ntot="node --test --test-only --test-reporter=tap"
alias ntot1="node --test --test-concurrency=1 --test-only --test-reporter=tap"

function ntow
  NODE_OPTIONS="--test --test-only" wtfnode $argv
end

function ntow1
  NODE_OPTIONS="--test --test-only" wtfnode $argv
end