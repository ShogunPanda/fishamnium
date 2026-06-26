use crate::config::{EditorConfig, GitConfig, NodeConfig, PromptTemplate, PromptThemeConfig, PromptUserConfig};
use std::collections::BTreeMap;

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
  "compact".to_string()
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
  [
    (
      "minimal",
      "<user>\u{E0B6}</><user_text> \u{F007} </><main> \u{EF09} {host} {git_status} </><end>\u{E0B0} </>",
    ),
    (
      "compact",
      "<user>\u{E0B6}</><user_text> \u{F007} {user} </><main> \u{EF09} {host} {git_status} </><end>\u{E0B0} </>",
    ),
    (
      "default",
      "<user>\u{E0B6}</><user_text> \u{F007} {user} </><main> \u{EF09} {host} \u{F07B} {path} \u{E0A0} {git_branch} {git_status} </><end>\u{E0B0} </>",
    ),
    (
      "extended",
      "<time>\u{E0B6} \u{E384} {time} </><path>\u{E0B0} \u{F07B} {full_path} \u{E0A0} {git_branch} {git_hash} {git_status} </><path_end>\u{E0B4}</>\n<user>\u{E0B6}</><user_text> \u{F007} {user} </><main> \u{EF09} {host} </><end>\u{E0B0} </>",
    ),
    (
      "full",
      "<time>\u{E0B6} \u{F073} {date_time} </><path_full>\u{E0B0} \u{F07B} {full_path} \u{E0A0} {git_branch} {git_hash} </><path_full_end>\u{E0B4}</> {git_status}\n<user>\u{E0B6}</><user_text> \u{F007} {user} </><main> \u{EF09} {host}{node}{rust}{ruby}{go} </><end>\u{E0B0} </>",
    ),
  ]
  .into_iter()
  .map(|(name, template)| {
    (
      name.to_string(),
      PromptThemeConfig {
        user: PromptUserConfig {
          regular: "hex:#008800 bold".to_string(),
          root: "hex:#cc0000 bold".to_string(),
        },
        styles: prompt_theme_styles(),
        template: PromptTemplate::String(template.to_string()),
      },
    )
  })
  .collect()
}

fn prompt_theme_styles() -> BTreeMap<String, String> {
  [
    ("user_text", "hex:#ffffff bg_hex:008800 bold"),
    ("main", "hex:#000000 bg_hex:ffdf00 bold"),
    ("end", "hex:#ffdf00 bold"),
    ("time", "hex:#ffffff bg_hex:013482 bold"),
    ("path", "hex:#ffffff bg_hex:0088e2 bold"),
    ("path_end", "hex:#0088e2"),
    ("path_full", "hex:#ffffff bg_hex:005be4 bold"),
    ("path_full_end", "hex:#005be4"),
  ]
  .into_iter()
  .map(|(name, styles)| (name.to_string(), styles.to_string()))
  .collect()
}
