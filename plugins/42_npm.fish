set -x -g PATH ./node_modules/.bin $PATH

alias ni="npm install"
alias nid="npm install -D"
alias nr="npm run"
alias nt="npm test"
alias nrb="npm run build"
alias nre="npm run dev"
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
alias pnrs="pnpm run server"
alias pnrf="pnpm run format"
alias pnrl="pnpm run lint"
alias pnrd="pnpm run deploy"
alias pno="pnpm outdated"
alias pnu="pnpm update"

function nrs -d "Interactively run a script using npm"
  set scripts $(yq -o tsv -eMP ".scripts | to_entries | map([.key])" package.json 2>/dev/null)
  test ! $status -eq 0; and return

  set runner $RUNNER
  test -z "$runner"; and set runner "npm"

  set prompt "--> Which script do you want to run? "
  set colors "prompt:3:bold,bg+:-1,fg+:2:bold,pointer:2:bold,hl:-1:underline,hl+:2:bold:underline"
  set height $(math $(count $scripts) + 1)

  set choice $(string join0 $scripts | fzf --read0 -e --prompt $prompt --info=hidden --preview-window=hidden --height $height --reverse --color $colors)
  
  if test $status -eq 0
    echo -e "\x1b[33m--> $runner run $choice\x1b[0m"
    $runner run $choice
  end
end

function pnrs -d "Interactively run a script using pnpm"
  RUNNER=pnpm nrs
end
