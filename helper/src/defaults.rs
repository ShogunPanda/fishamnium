use crate::config::{EditorConfig, GitConfig, NodeConfig};

pub const COLORS_WHITE: &str = "FFFFFF";
pub const COLORS_BLACK: &str = "000000";
pub const COLORS_LIGHTGREEN: &str = "00CC00";
pub const COLORS_YELLOW: &str = "FFDF00";
pub const COLORS_MAGENTA: &str = "C800E2";
pub const COLORS_BLUE: &str = "005be4";
pub const COLORS_GRAY: &str = "808080";
pub const COLORS_LIGHTGRAY: &str = "C0C0C0";
pub const COLORS_ORANGE: &str = "F83B19";
pub const COLORS_LIGHT_RED: &str = "CC0000";
pub const COLORS_LIGHT_GREEN: &str = "00CC00";
pub const COLORS_LIGHT_CYAN: &str = "0088E2";
pub const COLORS_DARK_RED: &str = "EE0000";
pub const COLORS_DARK_GREEN: &str = "00EE00";
pub const COLORS_DARK_CYAN: &str = "5EBBF9";

pub fn colors_white() -> String {
  COLORS_WHITE.to_string()
}

pub fn colors_black() -> String {
  COLORS_BLACK.to_string()
}

pub fn colors_lightgreen() -> String {
  COLORS_LIGHTGREEN.to_string()
}

pub fn colors_yellow() -> String {
  COLORS_YELLOW.to_string()
}

pub fn colors_magenta() -> String {
  COLORS_MAGENTA.to_string()
}

pub fn colors_blue() -> String {
  COLORS_BLUE.to_string()
}

pub fn colors_gray() -> String {
  COLORS_GRAY.to_string()
}

pub fn colors_lightgray() -> String {
  COLORS_LIGHTGRAY.to_string()
}

pub fn colors_orange() -> String {
  COLORS_ORANGE.to_string()
}

pub fn colors_light_red() -> String {
  COLORS_LIGHT_RED.to_string()
}

pub fn colors_light_green() -> String {
  COLORS_LIGHT_GREEN.to_string()
}

pub fn colors_light_cyan() -> String {
  COLORS_LIGHT_CYAN.to_string()
}

pub fn colors_dark_red() -> String {
  COLORS_DARK_RED.to_string()
}

pub fn colors_dark_green() -> String {
  COLORS_DARK_GREEN.to_string()
}

pub fn colors_dark_cyan() -> String {
  COLORS_DARK_CYAN.to_string()
}

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

pub fn theme() -> String {
  "dark".to_string()
}

pub fn is_theme(value: &String) -> bool {
  value == &theme()
}
