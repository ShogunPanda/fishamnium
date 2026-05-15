use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::error::Error;
use std::fs;
use std::path::Path;
use std::sync::{Arc, OnceLock};

use crate::bookmarks::BookmarkConfig;
use crate::defaults::*;
use crate::env::Environment;

static EMPTY_RESPONSE: OnceLock<Arc<Vec<u8>>> = OnceLock::new();
static EMPTY_OK_RESPONSE: OnceLock<Arc<Vec<u8>>> = OnceLock::new();

pub fn empty_response() -> Arc<Vec<u8>> {
  Arc::clone(EMPTY_RESPONSE.get_or_init(|| Arc::new(Vec::new())))
}

pub fn empty_ok_response() -> Arc<Vec<u8>> {
  Arc::clone(EMPTY_OK_RESPONSE.get_or_init(|| Arc::new(b"0".to_vec())))
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

  #[serde(default = "git_task_matchers", skip_serializing_if = "is_git_task_matchers")]
  pub task_matchers: String,

  #[serde(
    default = "git_task_name_matchers",
    skip_serializing_if = "is_git_task_name_matchers"
  )]
  pub task_name_matchers: String,

  #[serde(default = "git_task_template", skip_serializing_if = "is_git_task_template")]
  pub task_template: String,

  #[serde(default = "git_open_path", skip_serializing_if = "is_git_open_path")]
  pub open_path: String,

  #[serde(default = "git_release_prefix", skip_serializing_if = "is_git_release_prefix")]
  pub release_prefix: String,

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

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Config {
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

  #[serde(default = "profile", skip_serializing_if = "is_profile")]
  pub profile: String,
}

impl Config {
  pub fn current_path() -> Result<String, Box<dyn Error>> {
    let file_name = ".fishamnium.yml";
    let mut directory = std::env::current_dir()?;

    loop {
      let candidate = directory.join(file_name);

      if candidate.is_file() {
        return Ok(candidate.to_string_lossy().into_owned());
      }

      if !directory.pop() {
        break;
      }
    }

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

  pub fn save(&self, path: &Path) -> Result<(), Box<dyn Error>> {
    if let Some(parent) = path.parent() {
      fs::create_dir_all(parent)?;
    }

    fs::write(path, serde_yaml::to_string(self)?)?;
    Ok(())
  }

  pub fn get(&self, selector: Option<&str>, fallback: &[&str]) -> Result<String, Box<dyn Error>> {
    let fallback = fallback.join(" ");

    let selector = match selector {
      Some(selector) if !selector.trim().is_empty() => selector,
      _ => return Ok(fallback.to_string()),
    };

    let segments = selector
      .trim()
      .trim_start_matches('.')
      .split('.')
      .filter(|segment| !segment.is_empty())
      .collect::<Vec<_>>();

    let value = match segments.as_slice() {
      ["git", "branch"] => Some(self.git.branch.as_str()),
      ["git", "remote"] => Some(self.git.remote.as_str()),
      ["git", "root"] => Some(self.git.root.as_str()),
      ["git", "taskMatchers"] => Some(self.git.task_matchers.as_str()),
      ["git", "taskNameMatchers"] => Some(self.git.task_name_matchers.as_str()),
      ["git", "taskTemplate"] => Some(self.git.task_template.as_str()),
      ["git", "openPath"] => Some(self.git.open_path.as_str()),
      ["git", "releasePrefix"] => Some(self.git.release_prefix.as_str()),
      ["git", "upstreamRemote"] => Some(self.git.upstream_remote.as_str()),
      ["git", "approvalMessage"] => Some(self.git.approval_message.as_str()),
      ["node", "runner"] => Some(self.node.runner.as_str()),
      ["editor", "terminal"] => Some(self.editor.terminal.as_str()),
      ["editor", "graphical"] => Some(self.editor.graphical.as_str()),
      ["bookmarksExportPrefix"] => Some(self.bookmarks_export_prefix.as_str()),
      ["profile"] => Some(self.profile.as_str()),
      ["bookmarks", key, "path"] => self.bookmarks.get(*key).map(|bookmark| bookmark.path.as_str()),
      ["bookmarks", key, "name"] => self.bookmarks.get(*key).map(|bookmark| bookmark.name.as_str()),
      ["bookmarks", key, "recursive"] => self
        .bookmarks
        .get(*key)
        .and_then(|bookmark| bookmark.recursive.as_deref()),
      _ => None,
    };

    Ok(value.unwrap_or(&fallback).to_string())
  }
}

impl Default for Config {
  fn default() -> Self {
    Self {
      git: GitConfig::default(),
      bookmarks: BTreeMap::new(),
      bookmarks_export_prefix: bookmarks_export_prefix(),
      node: NodeConfig::default(),
      editor: EditorConfig::default(),
      profile: profile(),
    }
  }
}

impl Default for GitConfig {
  fn default() -> Self {
    Self {
      branch: git_branch(),
      remote: git_remote(),
      root: git_root(),
      task_matchers: git_task_matchers(),
      task_name_matchers: git_task_name_matchers(),
      task_template: git_task_template(),
      open_path: git_open_path(),
      release_prefix: git_release_prefix(),
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
