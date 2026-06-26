use serde::{Deserialize, Serialize};
use serde_yaml::Value;
use std::collections::BTreeMap;
use std::error::Error;
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::process::id;
use std::sync::{Arc, OnceLock};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::bookmarks::BookmarkConfig;
use crate::defaults::*;
use crate::env::Environment;

static EMPTY_RESPONSE: OnceLock<Arc<Vec<u8>>> = OnceLock::new();

pub fn empty_response() -> Arc<Vec<u8>> {
  Arc::clone(EMPTY_RESPONSE.get_or_init(|| Arc::new(Vec::new())))
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct GitConfig {
  #[serde(default = "git_branch", skip_serializing_if = "is_git_branch")]
  pub branch: String,

  #[serde(default = "git_remote", skip_serializing_if = "is_git_remote")]
  pub remote: String,

  #[serde(default = "git_root", skip_serializing_if = "is_git_root")]
  pub root: String,

  #[serde(default = "git_upstream_remote", skip_serializing_if = "is_git_upstream_remote")]
  pub upstream_remote: String,

  #[serde(default = "git_approval_message", skip_serializing_if = "is_git_approval_message")]
  pub approval_message: String,
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct NodeConfig {
  #[serde(default = "node_runner", skip_serializing_if = "is_node_runner")]
  pub runner: String,
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct EditorConfig {
  #[serde(default = "editor_terminal", skip_serializing_if = "is_editor_terminal")]
  pub terminal: String,

  #[serde(default = "editor_graphical", skip_serializing_if = "is_editor_graphical")]
  pub graphical: String,
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ColorsConfig {
  #[serde(default, skip_serializing_if = "is_light_color_theme_config")]
  pub light: ColorThemeConfig,

  #[serde(
    default = "ColorThemeConfig::dark",
    skip_serializing_if = "is_dark_color_theme_config"
  )]
  pub dark: ColorThemeConfig,
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ColorThemeConfig {
  #[serde(default = "colors_white")]
  pub white: String,

  #[serde(default = "colors_black")]
  pub black: String,

  #[serde(default = "colors_lightgreen")]
  pub lightgreen: String,

  #[serde(default = "colors_yellow")]
  pub yellow: String,

  #[serde(default = "colors_magenta")]
  pub magenta: String,

  #[serde(default = "colors_blue")]
  pub blue: String,

  #[serde(default = "colors_gray")]
  pub gray: String,

  #[serde(default = "colors_lightgray")]
  pub lightgray: String,

  #[serde(default = "colors_orange")]
  pub orange: String,

  #[serde(default = "colors_light_red")]
  pub red: String,

  #[serde(default = "colors_light_green")]
  pub green: String,

  #[serde(default = "colors_light_cyan")]
  pub cyan: String,

  #[serde(default = "colors_black")]
  pub foreground: String,

  #[serde(default = "colors_light_cyan")]
  pub primary: String,

  #[serde(default = "colors_magenta")]
  pub secondary: String,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PromptThemeConfig {
  pub user: PromptUserConfig,

  #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
  pub styles: BTreeMap<String, String>,

  pub template: PromptTemplate,
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(untagged)]
pub enum PromptTemplate {
  String(String),
  Lines(Vec<String>),
}

impl PromptTemplate {
  pub fn render(&self) -> String {
    match self {
      Self::String(template) => template.clone(),
      Self::Lines(lines) => lines.join("\n"),
    }
  }
}

#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PromptUserConfig {
  pub regular: String,
  pub root: String,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Config {
  #[serde(default, skip_serializing_if = "Vec::is_empty")]
  pub hosts: Vec<String>,

  #[serde(default, skip_serializing_if = "is_git_config")]
  pub git: GitConfig,

  #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
  pub bookmarks: BTreeMap<String, BookmarkConfig>,

  #[serde(
    default = "bookmarks_export_prefix",
    skip_serializing_if = "is_bookmarks_export_prefix"
  )]
  pub bookmarks_export_prefix: String,

  #[serde(default, skip_serializing_if = "is_node_config")]
  pub node: NodeConfig,

  #[serde(default, skip_serializing_if = "is_editor_config")]
  pub editor: EditorConfig,

  #[serde(default = "theme", skip_serializing_if = "is_theme")]
  pub theme: String,

  #[serde(default = "prompt", skip_serializing_if = "is_prompt")]
  pub prompt: String,

  #[serde(
    default = "prompt_narrow",
    rename = "prompt_narrow",
    alias = "promptNarrow",
    skip_serializing_if = "is_prompt_narrow"
  )]
  pub prompt_narrow: String,

  #[serde(
    default = "prompt_narrow_threshold",
    rename = "prompt_narrow_threshold",
    alias = "promptNarrowThreshold",
    skip_serializing_if = "is_prompt_narrow_threshold"
  )]
  pub prompt_narrow_threshold: u16,

  #[serde(default, skip_serializing_if = "is_colors_config")]
  pub colors: ColorsConfig,

  #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
  pub themes: BTreeMap<String, PromptThemeConfig>,
}

impl Config {
  pub fn current_path() -> Result<String, Box<dyn Error>> {
    Ok(Environment::new()?.config)
  }

  pub fn load_current() -> Result<Self, Box<dyn Error>> {
    Self::load(Path::new(&Self::current_path()?))
  }

  pub fn load(path: &Path) -> Result<Self, Box<dyn Error>> {
    if !path.is_file() {
      return Ok(Self::default());
    }

    Ok(serde_yaml::from_str(&fs::read_to_string(path)?)?)
  }

  pub fn save_theme(path: &Path, theme: &str) -> Result<(), Box<dyn Error>> {
    let mut value = Self::load_value(path)?;
    Self::insert_value(&mut value, &["theme"], serde_yaml::to_value(theme)?);
    Self::write(path, &serde_yaml::to_string(&value)?)?;
    Ok(())
  }

  pub fn save_bookmarks(path: &Path, bookmarks: &BTreeMap<String, BookmarkConfig>) -> Result<(), Box<dyn Error>> {
    let mut value = Self::load_value(path)?;

    if bookmarks.is_empty() {
      Self::remove_value(&mut value, "bookmarks");
    } else {
      Self::insert_value(&mut value, &["bookmarks"], serde_yaml::to_value(bookmarks)?);
    }

    Self::write(path, &serde_yaml::to_string(&value)?)?;
    Ok(())
  }

  pub fn get(&self, selector: Option<&str>, fallback: &[&str]) -> Result<String, Box<dyn Error>> {
    let fallback = fallback.join(" ");

    let selector = match selector {
      Some(selector) if !selector.trim().is_empty() => selector,
      _ => return Ok(fallback.to_string()),
    };

    let value = self.to_lookup_value()?;
    let mut current = Some(&value);

    for segment in selector
      .trim()
      .trim_start_matches('.')
      .split('.')
      .filter(|segment| !segment.is_empty())
    {
      current = match current {
        Some(Value::Mapping(mapping)) => mapping.get(Value::String(segment.to_string())),
        Some(Value::Sequence(sequence)) => segment.parse::<usize>().ok().and_then(|index| sequence.get(index)),
        _ => None,
      };
    }

    Ok(Self::value_to_string(current).unwrap_or(fallback))
  }

  fn value_to_string(value: Option<&Value>) -> Option<String> {
    match value? {
      Value::String(value) => Some(value.clone()),
      Value::Number(value) => Some(value.to_string()),
      Value::Bool(value) => Some(value.to_string()),
      Value::Sequence(values) => Some(
        values
          .iter()
          .filter_map(|value| Self::value_to_string(Some(value)))
          .collect::<Vec<_>>()
          .join(" "),
      ),
      _ => None,
    }
  }

  fn to_lookup_value(&self) -> Result<Value, Box<dyn Error>> {
    let mut value = serde_yaml::to_value(self)?;

    Self::insert_value(&mut value, &["hosts"], serde_yaml::to_value(&self.hosts)?);
    Self::insert_value(&mut value, &["git", "branch"], serde_yaml::to_value(&self.git.branch)?);
    Self::insert_value(&mut value, &["git", "remote"], serde_yaml::to_value(&self.git.remote)?);
    Self::insert_value(&mut value, &["git", "root"], serde_yaml::to_value(&self.git.root)?);
    Self::insert_value(
      &mut value,
      &["git", "upstreamRemote"],
      serde_yaml::to_value(&self.git.upstream_remote)?,
    );
    Self::insert_value(
      &mut value,
      &["git", "approvalMessage"],
      serde_yaml::to_value(&self.git.approval_message)?,
    );
    Self::insert_value(
      &mut value,
      &["node", "runner"],
      serde_yaml::to_value(&self.node.runner)?,
    );
    Self::insert_value(
      &mut value,
      &["editor", "terminal"],
      serde_yaml::to_value(&self.editor.terminal)?,
    );
    Self::insert_value(
      &mut value,
      &["editor", "graphical"],
      serde_yaml::to_value(&self.editor.graphical)?,
    );
    Self::insert_value(&mut value, &["theme"], serde_yaml::to_value(&self.theme)?);
    Self::insert_value(&mut value, &["prompt"], serde_yaml::to_value(&self.prompt)?);
    Self::insert_value(
      &mut value,
      &["prompt_narrow"],
      serde_yaml::to_value(&self.prompt_narrow)?,
    );
    Self::insert_value(
      &mut value,
      &["prompt_narrow_threshold"],
      serde_yaml::to_value(self.prompt_narrow_threshold)?,
    );
    Self::insert_value(&mut value, &["colors"], serde_yaml::to_value(&self.colors)?);
    Self::insert_value(&mut value, &["themes"], serde_yaml::to_value(&self.themes)?);
    Self::insert_value(
      &mut value,
      &["bookmarksExportPrefix"],
      serde_yaml::to_value(&self.bookmarks_export_prefix)?,
    );

    Ok(value)
  }

  fn insert_value(root: &mut Value, path: &[&str], value: Value) {
    let Some((segment, rest)) = path.split_first() else {
      *root = value;
      return;
    };

    if !matches!(root, Value::Mapping(_)) {
      *root = Value::Mapping(Default::default());
    }

    let Value::Mapping(mapping) = root else {
      return;
    };
    let key = Value::String((*segment).to_string());

    if rest.is_empty() {
      mapping.insert(key, value);
    } else {
      Self::insert_value(
        mapping.entry(key).or_insert(Value::Mapping(Default::default())),
        rest,
        value,
      );
    }
  }

  fn remove_value(root: &mut Value, key: &str) {
    let Value::Mapping(mapping) = root else {
      return;
    };

    mapping.remove(Value::String(key.to_string()));
  }

  fn load_value(path: &Path) -> Result<Value, Box<dyn Error>> {
    if !path.is_file() {
      return Ok(Value::Mapping(Default::default()));
    }

    Ok(serde_yaml::from_str(&fs::read_to_string(path)?)?)
  }

  fn write(path: &Path, output: &str) -> Result<(), Box<dyn Error>> {
    if let Some(parent) = path.parent() {
      fs::create_dir_all(parent)?;
    }

    let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_nanos();
    let temporary = path.with_extension(format!("tmp.{}.{}", id(), now));
    let mut file = File::create(&temporary)?;
    file.write_all(output.as_bytes())?;
    file.sync_all()?;
    fs::rename(temporary, path)?;
    Ok(())
  }
}

impl Default for Config {
  fn default() -> Self {
    Self {
      hosts: Vec::new(),
      git: GitConfig::default(),
      bookmarks: BTreeMap::new(),
      bookmarks_export_prefix: bookmarks_export_prefix(),
      node: NodeConfig::default(),
      editor: EditorConfig::default(),
      theme: theme(),
      prompt: prompt(),
      prompt_narrow: prompt_narrow(),
      prompt_narrow_threshold: prompt_narrow_threshold(),
      colors: ColorsConfig::default(),
      themes: prompt_themes(),
    }
  }
}

impl Default for GitConfig {
  fn default() -> Self {
    Self {
      branch: git_branch(),
      remote: git_remote(),
      root: git_root(),
      upstream_remote: git_upstream_remote(),
      approval_message: git_approval_message(),
    }
  }
}

impl Default for NodeConfig {
  fn default() -> Self {
    Self { runner: node_runner() }
  }
}

impl Default for EditorConfig {
  fn default() -> Self {
    Self {
      terminal: editor_terminal(),
      graphical: editor_graphical(),
    }
  }
}

impl Default for ColorsConfig {
  fn default() -> Self {
    Self {
      light: ColorThemeConfig::default(),
      dark: ColorThemeConfig::dark(),
    }
  }
}

impl Default for ColorThemeConfig {
  fn default() -> Self {
    Self {
      white: colors_white(),
      black: colors_black(),
      lightgreen: colors_lightgreen(),
      yellow: colors_yellow(),
      magenta: colors_magenta(),
      blue: colors_blue(),
      gray: colors_gray(),
      lightgray: colors_lightgray(),
      orange: colors_orange(),
      red: colors_light_red(),
      green: colors_light_green(),
      cyan: colors_light_cyan(),
      foreground: colors_black(),
      primary: colors_light_cyan(),
      secondary: colors_magenta(),
    }
  }
}

impl ColorThemeConfig {
  fn dark() -> Self {
    Self {
      white: colors_white(),
      black: colors_black(),
      lightgreen: colors_lightgreen(),
      yellow: colors_yellow(),
      magenta: colors_magenta(),
      blue: colors_blue(),
      gray: colors_gray(),
      lightgray: colors_lightgray(),
      orange: colors_orange(),
      red: colors_dark_red(),
      green: colors_dark_green(),
      cyan: colors_dark_cyan(),
      foreground: colors_white(),
      primary: colors_yellow(),
      secondary: colors_dark_cyan(),
    }
  }
}

fn is_colors_config(value: &ColorsConfig) -> bool {
  value == &ColorsConfig::default()
}

fn is_light_color_theme_config(value: &ColorThemeConfig) -> bool {
  value == &ColorThemeConfig::default()
}

fn is_dark_color_theme_config(value: &ColorThemeConfig) -> bool {
  value == &ColorThemeConfig::dark()
}
