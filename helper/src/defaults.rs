use crate::config::{EditorConfig, GitConfig, NodeConfig, PromptColorsConfig, PromptTemplate, PromptThemeConfig};
use serde::Deserialize;
use std::collections::BTreeMap;
use std::fs;
use std::path::PathBuf;

#[derive(Deserialize)]
struct DefaultConfig {
  prompts: BTreeMap<String, PromptThemeConfig>,
}

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

pub fn prompt() -> String {
  "default".to_string()
}

pub fn is_prompt(value: &String) -> bool {
  value == &prompt()
}

pub fn prompt_narrow() -> String {
  "xsmall".to_string()
}

pub fn is_prompt_narrow(value: &String) -> bool {
  value == &prompt_narrow()
}

pub fn prompt_narrow_threshold() -> u16 {
  100
}

pub fn is_prompt_narrow_threshold(value: &u16) -> bool {
  *value == prompt_narrow_threshold()
}

pub fn prompt_themes() -> BTreeMap<String, PromptThemeConfig> {
  [(
    "default".to_string(),
    PromptThemeConfig {
      colors: PromptColorsConfig::default(),
      styles: BTreeMap::new(),
      template: PromptTemplate::String("{user}@{host} $>".to_string()),
    },
  )]
  .into_iter()
  .collect()
}

pub fn installed_prompt_themes() -> BTreeMap<String, PromptThemeConfig> {
  let Ok(home) = std::env::var("HOME") else {
    return prompt_themes();
  };

  let path = PathBuf::from(home)
    .join(".local")
    .join("share")
    .join("fishamnium")
    .join("default.yml");

  fs::read_to_string(path)
    .ok()
    .and_then(|content| serde_yaml::from_str::<DefaultConfig>(&content).ok())
    .map(|config| config.prompts)
    .unwrap_or_else(prompt_themes)
}
