use crate::bookmarks::Bookmark;
use crate::colors::Colors;
use crate::config::Config;
use nix::unistd::gethostname;
use std::{collections::HashSet, error::Error, path::PathBuf};

pub struct Environment {
  hostname: String,
  pub root: String,
  pub config: String,
  config_root: String,
}

impl Environment {
  pub fn new() -> Result<Self, Box<dyn Error>> {
    let home = std::env::var("HOME")?;
    let root = PathBuf::from(&home).join(".local").join("share").join("fishamnium");
    let config_root = PathBuf::from(&home).join(".config").join("fishamnium");
    let hostname = gethostname()
      .map_err(std::io::Error::other)?
      .to_string_lossy()
      .split(".")
      .next()
      .unwrap_or("")
      .to_string();

    let host_config = config_root.join(format!("config.{hostname}.yml"));

    Ok(Self {
      hostname,
      root: root.to_string_lossy().into_owned(),
      config: if host_config.is_file() {
        host_config
      } else {
        config_root.join("config.yml")
      }
      .to_string_lossy()
      .into_owned(),
      config_root: config_root.to_string_lossy().into_owned(),
    })
  }

  pub fn to_response(&self, existing_path: Option<&str>) -> Result<Vec<u8>, Box<dyn Error>> {
    let paths = Self::paths(existing_path);
    let config = Config::load_current()?;

    let mut response = format!(
      "FISHAMNIUM_HOST={}\nFISHAMNIUM_ROOT={}\nFISHAMNIUM_CONFIG_ROOT={}\nFISHAMNIUM_CONFIG={}\nFISHAMNIUM_THEME={}\nFISHAMNIUM_THEME_NARROW={}\nFISHAMNIUM_THEME_NARROW_THRESHOLD={}\nPATH={}\nEDITOR={}\nGEDITOR={}\n",
      Environment::quote_env_value(&self.hostname),
      Environment::quote_env_value(&self.root),
      Environment::quote_env_value(&self.config_root),
      Environment::quote_env_value(&self.config),
      Environment::quote_env_value(&config.prompt),
      Environment::quote_env_value(&config.prompt_narrow),
      Environment::quote_env_value(&config.prompt_narrow_threshold.to_string()),
      Environment::quote_env_value(&paths.join(":")),
      Environment::quote_env_value(&config.editor.terminal),
      Environment::quote_env_value(&config.editor.graphical),
    );

    for (name, value) in &config.env {
      response.push_str(name);
      response.push('=');
      response.push_str(&Self::quote_env_value(value));
      response.push('\n');
    }

    Ok(response.into_bytes())
  }

  pub fn to_fish_response(&self, existing_path: Option<&str>) -> Result<Vec<u8>, Box<dyn Error>> {
    let paths = Self::paths(existing_path);
    let config = Config::load_current()?;

    let mut response = String::new();
    Self::push_fish_variable(&mut response, "FISHAMNIUM_HOST", &[self.hostname.as_str()]);
    Self::push_fish_variable(&mut response, "FISHAMNIUM_ROOT", &[self.root.as_str()]);
    Self::push_fish_variable(&mut response, "FISHAMNIUM_CONFIG_ROOT", &[self.config_root.as_str()]);
    Self::push_fish_variable(&mut response, "FISHAMNIUM_CONFIG", &[self.config.as_str()]);
    Self::push_fish_variable(&mut response, "FISHAMNIUM_THEME", &[config.prompt.as_str()]);
    Self::push_fish_variable(
      &mut response,
      "FISHAMNIUM_THEME_NARROW",
      &[config.prompt_narrow.as_str()],
    );
    Self::push_fish_variable(
      &mut response,
      "FISHAMNIUM_THEME_NARROW_THRESHOLD",
      &[config.prompt_narrow_threshold.to_string().as_str()],
    );
    Self::push_fish_variable(
      &mut response,
      "PATH",
      &paths.iter().map(String::as_str).collect::<Vec<_>>(),
    );
    Self::push_fish_variable(&mut response, "EDITOR", &[config.editor.terminal.as_str()]);
    Self::push_fish_variable(&mut response, "GEDITOR", &[config.editor.graphical.as_str()]);

    for (name, value) in &config.env {
      Self::push_fish_variable(&mut response, name, &[value]);
    }

    Ok(response.into_bytes())
  }

  pub fn to_shell_response(existing_path: Option<&str>, theme: Option<&str>) -> Result<Vec<u8>, Box<dyn Error>> {
    let mut response = Colors::new(theme)?.to_fish_response();
    response.extend(Self::new()?.to_fish_response(existing_path)?);
    Ok(response)
  }

  pub fn quote_env_value(value: &str) -> String {
    let mut quoted = String::from("\"");

    for character in value.chars() {
      match character {
        '\\' => quoted.push_str("\\\\"),
        '"' => quoted.push_str("\\\""),
        '\n' => quoted.push_str("\\n"),
        '\r' => quoted.push_str("\\r"),
        '\t' => quoted.push_str("\\t"),
        character => quoted.push(character),
      }
    }

    quoted.push('"');
    quoted
  }

  pub fn quote_fish_value(value: &str) -> String {
    let mut quoted = String::from("\"");

    for character in value.chars() {
      match character {
        '\\' => quoted.push_str("\\\\"),
        '"' => quoted.push_str("\\\""),
        '$' => quoted.push_str("\\$"),
        '\n' => quoted.push_str("\\n"),
        '\r' => quoted.push_str("\\r"),
        '\t' => quoted.push_str("\\t"),
        character => quoted.push(character),
      }
    }

    quoted.push('"');
    quoted
  }

  pub fn push_fish_variable(response: &mut String, name: &str, values: &[&str]) {
    response.push_str("set -x -g ");
    response.push_str(name);

    for value in values {
      response.push(' ');
      response.push_str(&Self::quote_fish_value(value));
    }

    response.push('\n');
  }

  fn paths(existing_path: Option<&str>) -> Vec<String> {
    let mut paths = Vec::new();
    let mut seen = HashSet::new();

    let local = Bookmark::expand_home("~/.local").unwrap_or("/".into());
    let fishamnium = Bookmark::expand_home("~/.local/share/fishamnium").unwrap_or("/".into());

    for root in [
      "/",
      "/usr",
      "/usr/local",
      "/opt",
      "/opt/local",
      "/opt/homebrew",
      "/var",
      "/var/local",
      &local,
      &fishamnium,
    ] {
      for directory in ["bin", "sbin"] {
        let path = PathBuf::from(root).join(directory);

        if path.is_dir() {
          Self::push_path(&mut paths, &mut seen, path.to_string_lossy().into_owned());
        }
      }
    }

    Self::push_path(&mut paths, &mut seen, "./bin".to_string());

    for path in existing_path.unwrap_or("").split(':') {
      Self::push_path(&mut paths, &mut seen, path.to_string());
    }

    paths
  }

  fn push_path(paths: &mut Vec<String>, seen: &mut HashSet<String>, path: String) {
    if path.is_empty() || !seen.insert(path.clone()) {
      return;
    }

    paths.push(path);
  }
}
