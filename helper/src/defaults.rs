use crate::config::{EditorConfig, GitConfig, NodeConfig};

pub fn git_branch() -> String {
  "main".to_string()
}

pub fn is_git_branch(value: &String) -> bool {
  value == &git_branch()
}

pub fn git_remote() -> String {
  "origin".to_string()
}

pub fn is_git_remote(value: &String) -> bool {
  value == &git_remote()
}

pub fn git_root() -> String {
  "~/development".to_string()
}

pub fn is_git_root(value: &String) -> bool {
  value == &git_root()
}

pub fn git_task_matchers() -> String {
  [
    r"git@github\.com:(?<repo>.+)\.git https://github.com/@repo@/compare/@base@...@branch@?expand=1",
    r"https://github\.com/(?<repo>.+)\.git https://github.com/@repo@/compare/@base@...@branch@?expand=1",
    r"git@gitlab\.com:(?<repo>.+)\.git https://gitlab.com/@repo@/merge_requests/new?merge_request%5Btarget_branch%5D=@base@&merge_request%5Bsource_branch%5D=@branch@",
    r"https://gitlab\.com/(?<repo>.+)\.git https://gitlab.com/@repo@/merge_requests/new?merge_request%5Btarget_branch%5D=@base@&merge_request%5Bsource_branch%5D=@branch@",
  ]
  .join("\n")
}

pub fn is_git_task_matchers(value: &String) -> bool {
  value == &git_task_matchers()
}

pub fn git_task_name_matchers() -> String {
  r"$GIT_TASK_MATCHERS ^(?<task>[a-z0-9]*-?\d+)-{1,2} -{1,2}(?<task>[a-z0-9]*-?\d+)$".to_string()
}

pub fn is_git_task_name_matchers(value: &String) -> bool {
  value == &git_task_name_matchers()
}

pub fn git_task_template() -> String {
  "@message@ [#@task@]".to_string()
}

pub fn is_git_task_template(value: &String) -> bool {
  value == &git_task_template()
}

pub fn git_open_path() -> String {
  "/usr/bin/open".to_string()
}

pub fn is_git_open_path(value: &String) -> bool {
  value == &git_open_path()
}

pub fn git_release_prefix() -> String {
  "release-".to_string()
}

pub fn is_git_release_prefix(value: &String) -> bool {
  value == &git_release_prefix()
}

pub fn git_upstream_remote() -> String {
  "upstream".to_string()
}

pub fn is_git_upstream_remote(value: &String) -> bool {
  value == &git_upstream_remote()
}

pub fn git_approval_message() -> String {
  "LGTM!".to_string()
}

pub fn is_git_approval_message(value: &String) -> bool {
  value == &git_approval_message()
}

pub fn is_git_config(value: &GitConfig) -> bool {
  value == &GitConfig::default()
}

pub fn bookmarks_export_prefix() -> String {
  "B_".to_string()
}

pub fn is_bookmarks_export_prefix(value: &String) -> bool {
  value == &bookmarks_export_prefix()
}

pub fn node_runner() -> String {
  "npm".to_string()
}

pub fn is_node_runner(value: &String) -> bool {
  value == &node_runner()
}

pub fn is_node_config(value: &NodeConfig) -> bool {
  value == &NodeConfig::default()
}

pub fn editor_terminal() -> String {
  "nvim".to_string()
}

pub fn is_editor_terminal(value: &String) -> bool {
  value == &editor_terminal()
}

pub fn editor_graphical() -> String {
  "code".to_string()
}

pub fn is_editor_graphical(value: &String) -> bool {
  value == &editor_graphical()
}

pub fn is_editor_config(value: &EditorConfig) -> bool {
  value == &EditorConfig::default()
}

pub fn profile() -> String {
  "dark".to_string()
}

pub fn is_profile(value: &String) -> bool {
  value == &profile()
}
