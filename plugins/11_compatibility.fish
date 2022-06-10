function export
  set command $(echo $argv | tr '=' ' ')
  eval "set -x -g $command"
end