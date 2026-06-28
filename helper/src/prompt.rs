use crate::config::{Config, PromptThemeConfig, PromptThemeOverrideConfig, PromptUserColorConfig};
use crate::defaults::bundled_prompt_themes;
use git2::{Repository, Status, StatusOptions};
use jiff::Zoned;
use nix::unistd::{Uid, User};
use regex::Regex;
use std::collections::BTreeMap;
use std::error::Error;
use std::io::{Error as IoError, ErrorKind};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Arc;
use std::sync::OnceLock;
use tempera::{add_style, colorize_template};

pub struct Prompt;

struct PromptOptions {
  theme: Option<String>,
  width: Option<u16>,
  path: PathBuf,
}

struct GitInfo {
  branch: String,
  hash: String,
  status: String,
}

impl Prompt {
  pub fn handle(payload: &[&str]) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
    Ok(Arc::new(Self::render(&Self::parse_options(payload)?)?.into_bytes()))
  }

  fn render(options: &PromptOptions) -> Result<String, Box<dyn Error>> {
    let config = Config::load_current()?;
    let bundled_themes = bundled_prompt_themes();
    let defaults = Config::default();
    let theme_name = Self::theme_name(&config, options);
    let Some(theme) = config
      .prompts
      .get(&theme_name)
      .or_else(|| bundled_themes.get(&theme_name))
      .or_else(|| defaults.prompts.get("default"))
    else {
      return Err(IoError::new(ErrorKind::NotFound, format!("Prompt theme {theme_name} not found")).into());
    };
    let mut theme = theme.clone();
    Self::apply_overrides(&mut theme, &config.prompt_overrides);

    Self::register_styles(&theme)?;
    let template = Self::interpolate(&theme.template.render(), &Self::variables(options)?);
    Ok(Self::collapse_spaces(&colorize_template(&Self::preprocess_tags(
      &template,
    ))))
  }

  fn parse_options(payload: &[&str]) -> Result<PromptOptions, Box<dyn Error>> {
    let mut theme = None;
    let mut width = None;
    let mut path = std::env::current_dir()?;
    let mut index = 0;

    while index < payload.len() {
      match payload[index] {
        "--status" | "--pipestatus" | "--duration" => {
          index += 1;
          if index >= payload.len() {
            return Err(
              IoError::new(
                ErrorKind::InvalidInput,
                format!("Missing value for {}", payload[index - 1]),
              )
              .into(),
            );
          }
        }
        "--theme" => {
          index += 1;
          theme = Some(
            payload
              .get(index)
              .ok_or_else(|| IoError::new(ErrorKind::InvalidInput, "Missing value for --theme"))?
              .to_string(),
          );
        }
        "--width" => {
          index += 1;
          width = Some(
            payload
              .get(index)
              .ok_or_else(|| IoError::new(ErrorKind::InvalidInput, "Missing value for --width"))?
              .parse()?,
          );
        }
        "--path" => {
          index += 1;
          path = PathBuf::from(
            payload
              .get(index)
              .ok_or_else(|| IoError::new(ErrorKind::InvalidInput, "Missing value for --path"))?,
          );
        }
        argument => {
          return Err(IoError::new(ErrorKind::InvalidInput, format!("Unknown prompt option: {argument}")).into());
        }
      }

      index += 1;
    }

    Ok(PromptOptions { theme, width, path })
  }

  fn theme_name(config: &Config, options: &PromptOptions) -> String {
    if let Some(theme) = &options.theme {
      return theme.clone();
    }

    if options
      .width
      .is_some_and(|width| width < config.prompt_narrow_threshold)
    {
      config.prompt_narrow.clone()
    } else {
      config.prompt.clone()
    }
  }

  fn register_styles(theme: &PromptThemeConfig) -> Result<(), Box<dyn Error>> {
    let mut styles = BTreeMap::new();

    styles.insert("white".to_string(), vec!["hex:ffffff".to_string()]);
    styles.insert("black".to_string(), vec!["hex:000000".to_string()]);

    if let Some(user) = &theme.colors.user {
      Self::insert_user_color_styles(&mut styles, user);
    }

    if let Some(host) = &theme.colors.host {
      Self::insert_color_styles(&mut styles, "host", host);
    }

    if let Some(time) = &theme.colors.time {
      Self::insert_color_styles(&mut styles, "time", time);
    }

    if let Some(path) = &theme.colors.path {
      Self::insert_color_styles(&mut styles, "path", path);
    }

    for (name, definition) in &theme.styles {
      styles.insert(name.to_string(), Self::split_styles(definition));
    }

    for name in styles.keys() {
      let resolved = Self::resolve_style(name, &styles, &mut Vec::new())?;
      let resolved = resolved.iter().map(String::as_str).collect::<Vec<_>>();
      add_style(name, &resolved)?;
    }

    Ok(())
  }

  fn apply_overrides(theme: &mut PromptThemeConfig, overrides: &PromptThemeOverrideConfig) {
    if let Some(user) = &overrides.colors.user {
      if let Some(regular) = &user.regular {
        theme.colors.user.get_or_insert_with(|| PromptUserColorConfig {
          regular: regular.clone(),
          root: None,
        });
      }

      if let Some(user_theme) = &mut theme.colors.user {
        if let Some(regular) = &user.regular {
          user_theme.regular = regular.clone();
        }
        if let Some(root) = &user.root {
          user_theme.root = Some(root.clone());
        }
      }
    }

    if let Some(host) = &overrides.colors.host {
      theme.colors.host = Some(host.clone());
    }
    if let Some(time) = &overrides.colors.time {
      theme.colors.time = Some(time.clone());
    }
    if let Some(path) = &overrides.colors.path {
      theme.colors.path = Some(path.clone());
    }

    for (name, definition) in &overrides.styles {
      theme.styles.insert(name.clone(), definition.clone());
    }

    if let Some(template) = &overrides.template {
      theme.template = template.clone();
    }
  }

  fn insert_user_color_styles(styles: &mut BTreeMap<String, Vec<String>>, config: &PromptUserColorConfig) {
    let color = if Uid::effective().is_root() {
      config.root.as_deref().unwrap_or(&config.regular)
    } else {
      &config.regular
    };

    Self::insert_color_styles(styles, "user", color);
  }

  fn insert_color_styles(styles: &mut BTreeMap<String, Vec<String>>, name: &str, color: &str) {
    let color = color.trim().trim_start_matches('#');
    let foreground = vec![format!("hex:{color}")];
    let background = vec![format!("bg_hex:{color}")];
    let text = vec![format!("hex:{}", Self::readable_text_color(color))];

    styles.insert(name.to_string(), foreground.clone());
    styles.insert(format!("{name}_fg"), foreground);
    styles.insert(format!("{name}_bg"), background);
    styles.insert(format!("{name}_text"), text);
  }

  fn readable_text_color(background: &str) -> &'static str {
    let Some(brightness) = Self::perceived_brightness(background) else {
      return "ffffff";
    };

    if brightness > 186 { "000000" } else { "ffffff" }
  }

  fn perceived_brightness(color: &str) -> Option<u32> {
    if color.len() != 6 {
      return None;
    }

    let red = u32::from(u8::from_str_radix(&color[0..2], 16).ok()?);
    let green = u32::from(u8::from_str_radix(&color[2..4], 16).ok()?);
    let blue = u32::from(u8::from_str_radix(&color[4..6], 16).ok()?);

    Some((red * 299 + green * 587 + blue * 114) / 1000)
  }

  fn resolve_style(
    name: &str,
    styles: &BTreeMap<String, Vec<String>>,
    stack: &mut Vec<String>,
  ) -> Result<Vec<String>, Box<dyn Error>> {
    if stack.iter().any(|entry| entry == name) {
      return Err(IoError::new(ErrorKind::InvalidInput, format!("Recursive prompt style: {name}")).into());
    }

    let Some(definition) = styles.get(name) else {
      return Ok(vec![name.to_string()]);
    };

    stack.push(name.to_string());
    let mut resolved = Vec::new();
    for token in definition {
      resolved.extend(Self::resolve_style(token, styles, stack)?);
    }
    stack.pop();

    Ok(resolved)
  }

  fn split_styles(styles: &str) -> Vec<String> {
    styles
      .split_whitespace()
      .filter(|style| !style.is_empty())
      .map(ToString::to_string)
      .collect()
  }

  fn variables(options: &PromptOptions) -> Result<BTreeMap<String, String>, Box<dyn Error>> {
    let mut variables = BTreeMap::new();
    let user = User::from_uid(Uid::effective())?
      .map(|user| user.name)
      .or_else(|| std::env::var("USER").ok())
      .unwrap_or_default();
    let host = std::env::var("FISHAMNIUM_HOST").unwrap_or_else(|_| hostname());
    let git = Self::git_info(&options.path);

    variables.insert("user".to_string(), user);
    variables.insert("host".to_string(), host);
    variables.insert("path".to_string(), Self::short_path(&options.path));
    variables.insert("full_path".to_string(), Self::collapse_home(&options.path));
    variables.insert(
      "git_branch".to_string(),
      git.as_ref().map(|git| git.branch.clone()).unwrap_or_default(),
    );
    variables.insert(
      "git_hash".to_string(),
      git.as_ref().map(|git| git.hash.clone()).unwrap_or_default(),
    );
    variables.insert(
      "git_status".to_string(),
      git.as_ref().map(|git| git.status.clone()).unwrap_or_default(),
    );
    variables.insert("time".to_string(), Self::date("+%T"));
    variables.insert("date_time".to_string(), Self::date("+%F %T"));
    variables.insert(
      "node".to_string(),
      Self::tool_version(&options.path, "package.json", "node", &["--version"], " node:"),
    );
    variables.insert(
      "rust".to_string(),
      Self::tool_version(&options.path, "Cargo.toml", "rustc", &["--version"], " rust:"),
    );
    variables.insert(
      "ruby".to_string(),
      Self::tool_version(&options.path, "Gemfile", "ruby", &["--version"], " ruby:"),
    );
    variables.insert(
      "go".to_string(),
      Self::tool_version(&options.path, "go.mod", "go", &["version"], " go:"),
    );

    Ok(variables)
  }

  fn interpolate(template: &str, variables: &BTreeMap<String, String>) -> String {
    static APP_MATCHER: OnceLock<Regex> = OnceLock::new();
    static VARIABLE_MATCHER: OnceLock<Regex> = OnceLock::new();
    let has_app = ["node", "rust", "ruby", "go"]
      .iter()
      .any(|name| variables.get(*name).is_some_and(|value| !value.is_empty()));
    let template = APP_MATCHER
      .get_or_init(|| Regex::new(r"\{app:([^}]*)\}").expect("Invalid prompt app regex"))
      .replace_all(template, |captures: &regex::Captures| {
        if has_app {
          captures[1].to_string()
        } else {
          String::new()
        }
      })
      .into_owned();

    VARIABLE_MATCHER
      .get_or_init(|| Regex::new(r"\{\s*([a-zA-Z0-9_]+)\s*\}").expect("Invalid prompt variable regex"))
      .replace_all(&template, |captures: &regex::Captures| {
        variables.get(&captures[1]).cloned().unwrap_or_default()
      })
      .into_owned()
  }

  fn preprocess_tags(template: &str) -> String {
    template
      .replace("<bg_reset>", "\u{1b}[49m")
      .replace("<fg_reset>", "\u{1b}[39m")
  }

  fn collapse_spaces(prompt: &str) -> String {
    static SPACE_MATCHER: OnceLock<Regex> = OnceLock::new();

    SPACE_MATCHER
      .get_or_init(|| Regex::new(r" {2,}").expect("Invalid prompt space regex"))
      .replace_all(prompt, " ")
      .into_owned()
  }

  fn git_info(path: &Path) -> Option<GitInfo> {
    let repository = Repository::discover(path).ok()?;
    let head = repository.head().ok()?;
    let branch = head.shorthand().unwrap_or("HEAD").to_string();
    let hash = head.target().map(|hash| hash.to_string()).unwrap_or_default();
    let hash = hash.chars().take(7).collect::<String>();
    let mut status_options = StatusOptions::new();
    status_options.include_untracked(true).recurse_untracked_dirs(true);
    let statuses = repository.statuses(Some(&mut status_options)).ok()?;
    let mut modified = false;
    let mut untracked = false;
    let mut conflicted = false;

    for entry in statuses.iter() {
      let status = entry.status();
      modified |= status.intersects(
        Status::INDEX_MODIFIED
          | Status::INDEX_DELETED
          | Status::INDEX_RENAMED
          | Status::INDEX_TYPECHANGE
          | Status::WT_MODIFIED
          | Status::WT_DELETED
          | Status::WT_RENAMED
          | Status::WT_TYPECHANGE,
      );
      untracked |= status.contains(Status::WT_NEW);
      conflicted |= status.contains(Status::CONFLICTED);
    }

    let mut prompt_status = String::new();
    if untracked {
      prompt_status.push('\u{1F539}');
    }
    if conflicted {
      prompt_status.push('\u{1F53A}');
    }
    if modified {
      prompt_status.push('\u{1F538}');
    }

    Some(GitInfo {
      branch,
      hash,
      status: prompt_status,
    })
  }

  fn short_path(path: &Path) -> String {
    path
      .file_name()
      .map(|name| name.to_string_lossy().into_owned())
      .filter(|name| !name.is_empty())
      .unwrap_or_else(|| Self::collapse_home(path))
  }

  fn collapse_home(path: &Path) -> String {
    let path = path.to_string_lossy();
    let Ok(home) = std::env::var("HOME") else {
      return path.into_owned();
    };

    if path == home {
      "~".to_string()
    } else if let Some(rest) = path.strip_prefix(&format!("{home}/")) {
      format!("~/{rest}")
    } else {
      path.into_owned()
    }
  }

  fn date(format: &str) -> String {
    Zoned::now()
      .strftime(format.strip_prefix('+').unwrap_or(format))
      .to_string()
  }

  fn tool_version(path: &Path, marker: &str, command: &str, arguments: &[&str], prefix: &str) -> String {
    if !Self::find_upwards(path, marker) {
      return String::new();
    }

    Command::new(command)
      .args(arguments)
      .output()
      .ok()
      .filter(|output| output.status.success())
      .map(|output| {
        let output = String::from_utf8_lossy(&output.stdout);
        let version = output
          .split_whitespace()
          .find(|token| token.starts_with('v'))
          .or_else(|| output.split_whitespace().nth(1));
        version.map(|version| format!("{prefix}{version}")).unwrap_or_default()
      })
      .unwrap_or_default()
  }

  fn find_upwards(path: &Path, marker: &str) -> bool {
    let mut current = path;
    loop {
      if current.join(marker).exists() {
        return true;
      }

      let Some(parent) = current.parent() else {
        return false;
      };
      current = parent;
    }
  }
}

fn hostname() -> String {
  nix::unistd::gethostname()
    .map(|hostname| hostname.to_string_lossy().split('.').next().unwrap_or("").to_string())
    .unwrap_or_default()
}
