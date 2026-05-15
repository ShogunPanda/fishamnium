use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::error::Error;
use std::fs;
use std::path::Path;
use std::sync::{Arc, OnceLock};

use crate::bookmarks::BookmarkConfig;
use crate::env::Environment;

static EMPTY_RESPONSE: OnceLock<Arc<Vec<u8>>> = OnceLock::new();
static EMPTY_OK_RESPONSE: OnceLock<Arc<Vec<u8>>> = OnceLock::new();

pub fn empty_response() -> Arc<Vec<u8>> {
  Arc::clone(EMPTY_RESPONSE.get_or_init(|| Arc::new(Vec::new())))
}

pub fn empty_ok_response() -> Arc<Vec<u8>> {
  Arc::clone(EMPTY_OK_RESPONSE.get_or_init(|| Arc::new(b"0".to_vec())))
}

#[derive(Debug, Deserialize, Serialize)]
pub struct GitConfig {
  #[serde(default = "GitConfig::default_git_branch")]
  pub branch: String,

  #[serde(default = "GitConfig::default_git_root")]
  pub root: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Config {
  #[serde(default)]
  pub git: GitConfig,

  #[serde(default = "Config::default_bookmarks")]
  pub bookmarks: BTreeMap<String, BookmarkConfig>,

  #[serde(default = "Config::default_profile")]
  pub profile: String,
}

impl GitConfig {
  fn default_git_branch() -> String {
    "main".to_string()
  }

  fn default_git_root() -> String {
    "~/development".to_string()
  }
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

  fn default_bookmarks() -> BTreeMap<String, BookmarkConfig> {
    BTreeMap::new()
  }

  fn default_profile() -> String {
    "dark".to_string()
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

  pub fn get(&self, selector: Option<&str>, fallback: Option<&str>) -> Result<String, Box<dyn Error>> {
    let fallback = fallback.unwrap_or("");

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
      ["git", "root"] => Some(self.git.root.as_str()),
      ["profile"] => Some(self.profile.as_str()),
      ["bookmarks", key, "path"] => self.bookmarks.get(*key).map(|bookmark| bookmark.path.as_str()),
      ["bookmarks", key, "name"] => self.bookmarks.get(*key).map(|bookmark| bookmark.name.as_str()),
      ["bookmarks", key, "recursive"] => self
        .bookmarks
        .get(*key)
        .and_then(|bookmark| bookmark.recursive.as_deref()),
      _ => None,
    };

    Ok(value.unwrap_or(fallback).to_string())
  }
}

impl Default for Config {
  fn default() -> Self {
    Self {
      git: GitConfig::default(),
      bookmarks: Config::default_bookmarks(),
      profile: Config::default_profile(),
    }
  }
}

impl Default for GitConfig {
  fn default() -> Self {
    Self {
      branch: GitConfig::default_git_branch(),
      root: GitConfig::default_git_root(),
    }
  }
}
