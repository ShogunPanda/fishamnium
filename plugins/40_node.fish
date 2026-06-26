# ----- Writing functions -----

function nrc -d "Interactively run a script using npm"
  set scripts $($FISHAMNIUM_HELPER node scripts package.json 2>/dev/null)
  test ! $status -eq 0; and return

  set runner $RUNNER
  test -z "$runner"; and set runner $(__fishamnium_get_configuration .node.runner)

  set choice $(string join0 $scripts | $FISHAMNIUM_HELPER select --prompt "Which script do you want to run")
  
  if test $status -eq 0
    printf "%s%s--> %s run %s%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$runner" "$choice" "$FISHAMNIUM_COLOR_RESET"
    $runner run $choice
  end
end

function nic -d "Reinstall all packages ensuring a clean local folder"
  set runner $RUNNER
  test -z "$runner"; and set runner $(__fishamnium_get_configuration .node.runner)

  printf "%s%s--> rm -rf node_modules package-lock.json pnpm-lock.yaml yarn.lock%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$FISHAMNIUM_COLOR_RESET"
  rm -rf node_modules package-lock.json pnpm-lock.yaml yarn.lock

  printf "%s%s--> %s install%s\n" "$FISHAMNIUM_COLOR_BOLD" "$FISHAMNIUM_COLOR_FG_PRIMARY" "$runner" "$FISHAMNIUM_COLOR_RESET"
  $runner install
end

function pnrc -d "Interactively run a script using pnpm"
  RUNNER=pnpm nrc
end

function pnic -d "Reinstall all packages ensuring a clean local folder using pnpm"
  RUNNER=pnpm nic
end

# ----- Bootstrap -----
set -x -g PATH ./node_modules/.bin $PATH

# ----- Aliases -----

alias nt="node --test"
alias ntt="node --test --test-reporter=tap"
alias nt1="node --test --test-concurrency=1"
alias ntt1="node --test --test-reporter=tap-concurrency=1"

alias nto="node --test --test-only"
alias ntot="node --test --test-only --test-reporter=tap"
alias nto1="node --test --test-only --test-concurrency=1"
alias ntot1="node --test --test-only --test-reporter=tap-concurrency=1"

alias ni="npm install"
alias nid="npm install -D"
alias nr="npm run"
alias nrt="npm test"
alias nrb="npm run build"
alias nre="npm run dev"
alias nrs="npm run start"
alias nrv="npm run server"
alias nrf="npm run format"
alias nrl="npm run lint"
alias nrd="npm run deploy"
alias no="npm outdated"
alias nu="npm update"

alias pni="pnpm install"
alias pna="pnpm add"
alias pnad="pnpm add -D"
alias pnr="pnpm run"
alias pnrt="pnpm test"
alias pnrb="pnpm run build"
alias pnre="pnpm run dev"
alias pnrs="pnpm run start"
alias pnrv="pnpm run server"
alias pnrf="pnpm run format"
alias pnrl="pnpm run lint"
alias pnrd="pnpm run deploy"
alias pno="pnpm outdated"
alias pnu="pnpm update"

