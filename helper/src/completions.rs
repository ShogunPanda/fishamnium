use std::error::Error;
use std::io::{Error as IoError, ErrorKind};

pub struct Completions;

impl Completions {
  pub fn to_fish_response(payload: &[String]) -> Result<Vec<u8>, Box<dyn Error>> {
    if !payload.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Completions does not accept arguments").into());
    }

    Ok(FISH_COMPLETIONS.as_bytes().to_vec())
  }
}

const FISH_COMPLETIONS: &str = r#"function __fishamnium_helper_command
  set -l skip_next 0
  set -l tokens (commandline -opc)
  set -e tokens[1]

  for token in $tokens
    if test $skip_next -eq 1
      set skip_next 0
      continue
    end

    switch $token
      case --client
        set skip_next 1
      case '--client=*' --server '-*'
      case '*'
        printf "%s\n" $token
        return 0
    end
  end

  return 1
end

function __fishamnium_helper_using_command
  set -l command (__fishamnium_helper_command)
  test "$command" = "$argv[1]"
end

function __fishamnium_helper_argument_index
  set -l command $argv[1]
  set -l skip_next 0
  set -l found 0
  set -l index 0
  set -l tokens (commandline -opc)
  set -e tokens[1]

  for token in $tokens
    if test $skip_next -eq 1
      set skip_next 0
      continue
    end

    if test $found -eq 1
      set index (math $index + 1)
      continue
    end

    switch $token
      case --client
        set skip_next 1
      case '--client=*' --server '-*'
      case '*'
        if test $token = $command
          set found 1
        end
    end
  end

  printf "%s\n" $index
end

complete -c fishamnium -e
complete -c fishamnium -f

complete -c fishamnium -l server -d "Run the helper server"
complete -c fishamnium -l client -x -a "" -d "Connect to a TCP helper server"

complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a reload -d "Reload Fishamnium"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a pid -d "Print the helper server PID"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a env -d "Print shell environment variables"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a shell-environment -d "Print fish environment variables"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a colors -d "Print color variables"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a fzf-theme -d "Print fzf theme colors"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a vscode-theme -d "Print VS Code terminal colors"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a configuration-file -d "Print active configuration file"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a config -d "Read configuration values"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a configuration -d "Read configuration values"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a bookmarks -d "Manage bookmarks"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a tmux -d "Manage tmux sessions"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a exit -d "Terminate the helper server"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a quit -d "Terminate the helper server"
complete -c fishamnium -n "not __fishamnium_helper_command >/dev/null" -a completions -d "Print fish completions"

complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a list -d "List bookmarks"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a list-raw -d "List raw bookmarks"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a tsv -d "List bookmarks as TSV"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a vscode-projects -d "Print VS Code projects JSON"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a export -d "Export bookmarks as environment variables"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a autocomplete -d "Print bookmark completion rows"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a names -d "Print bookmark names"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a show -d "Print bookmark path"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a save -d "Save current directory as bookmark"
complete -c fishamnium -n "__fishamnium_helper_using_command bookmarks; and test (__fishamnium_helper_argument_index bookmarks) -eq 0" -a delete -d "Delete bookmark"

complete -c fishamnium -n "__fishamnium_helper_using_command tmux; and test (__fishamnium_helper_argument_index tmux) -eq 0" -a next-session -d "Print next available tmux session name"

complete -c fishamnium -n "__fishamnium_helper_using_command colors; and test (__fishamnium_helper_argument_index colors) -eq 0" -a light -d "Light theme"
complete -c fishamnium -n "__fishamnium_helper_using_command colors; and test (__fishamnium_helper_argument_index colors) -eq 0" -a dark -d "Dark theme"
complete -c fishamnium -n "__fishamnium_helper_using_command fzf-theme; and test (__fishamnium_helper_argument_index fzf-theme) -eq 0" -a light -d "Light theme"
complete -c fishamnium -n "__fishamnium_helper_using_command fzf-theme; and test (__fishamnium_helper_argument_index fzf-theme) -eq 0" -a dark -d "Dark theme"
complete -c fishamnium -n "__fishamnium_helper_using_command vscode-theme; and test (__fishamnium_helper_argument_index vscode-theme) -eq 0" -a light -d "Light theme"
complete -c fishamnium -n "__fishamnium_helper_using_command vscode-theme; and test (__fishamnium_helper_argument_index vscode-theme) -eq 0" -a dark -d "Dark theme"
complete -c fishamnium -n "__fishamnium_helper_using_command shell-environment; and test (__fishamnium_helper_argument_index shell-environment) -eq 1" -a light -d "Light theme"
complete -c fishamnium -n "__fishamnium_helper_using_command shell-environment; and test (__fishamnium_helper_argument_index shell-environment) -eq 1" -a dark -d "Dark theme"

complete -c fishamnium -n "__fishamnium_helper_using_command config; and test (__fishamnium_helper_argument_index config) -eq 0" -a format -d "Format a configuration file"
complete -c fishamnium -n "__fishamnium_helper_using_command configuration; and test (__fishamnium_helper_argument_index configuration) -eq 0" -a format -d "Format a configuration file"

for selector in \
  .hosts \
  .theme \
  .prompt \
  .prompt_narrow \
  .prompt_narrow_threshold \
  .bookmarksExportPrefix \
  .git.branch \
  .git.remote \
  .git.root \
  .git.taskMatchers \
  .git.taskNameMatchers \
  .git.taskTemplate \
  .git.openPath \
  .git.releasePrefix \
  .git.upstreamRemote \
  .git.approvalMessage \
  .node.runner \
  .editor.terminal \
  .editor.graphical
  complete -c fishamnium -n "__fishamnium_helper_using_command config; and test (__fishamnium_helper_argument_index config) -eq 0" -a $selector -d "Configuration selector"
  complete -c fishamnium -n "__fishamnium_helper_using_command configuration; and test (__fishamnium_helper_argument_index configuration) -eq 0" -a $selector -d "Configuration selector"
end
"#;
