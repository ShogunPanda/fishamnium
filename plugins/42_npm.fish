set -x -g PATH ./node_modules/.bin $PATH

alias ni="npm install"
alias nid="npm install -D"
alias nr="npm run"
alias nt="npm test"
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
alias pnt="pnpm test"
alias pnrb="pnpm run build"
alias pnre="pnpm run dev"
alias pnrs="pnpm run start"
alias pnrv="pnpm run server"
alias pnrf="pnpm run format"
alias pnrl="pnpm run lint"
alias pnrd="pnpm run deploy"
alias pno="pnpm outdated"
alias pnu="pnpm update"

function nrc -d "Interactively run a script using npm"
  set scripts $(yq -o tsv -eMP ".scripts | to_entries | map([.key])" package.json 2>/dev/null)
  test ! $status -eq 0; and return

  set runner $RUNNER
  test -z "$runner"; and set runner "npm"

  set prompt "--> Which script do you want to run? "
  # TODO@PI: See bookmarks
  set colors $FISHAMNIUM_INTERACTIVE_COLORS
  set height $(math $(count $scripts) + 1)

  set choice $(string join0 $scripts | fzf --read0 -e --prompt $prompt --info=hidden --preview-window=hidden --height $height --reverse --color $colors)
  
  if test $status -eq 0
    echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_PRIMARY--> $runner run $choice$FISHAMNIUM_COLOR_RESET"
    $runner run $choice
  end
end

function nic -d "Reinstall all packages ensuring a clean local folder"
  set runner $RUNNER
  test -z "$runner"; and set runner "npm"

  echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_PRIMARY--> rm -rf node_modules package-lock.json pnpm-lock.yaml yarn.lock"
  rm -rf node_modules package-lock.json pnpm-lock.yaml yarn.lock

  echo -e "$FISHAMNIUM_COLOR_BOLD$FISHAMNIUM_COLOR_PRIMARY--> $RUNNER install"
  $RUNNER install
end

function pnrc -d "Interactively run a script using pnpm"
  RUNNER=pnpm nrc
end

function pnic -d "Reinstall all packages ensuring a clean local folder using pnpm"
  RUNNER=pnpm nic
end
