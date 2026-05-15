use comfy_table::{Cell, Table, TableComponent};
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::error::Error;
use std::fs;
use std::io::{Error as IoError, ErrorKind};
use std::path::Path;
use std::path::PathBuf;
use std::sync::Arc;

use crate::colors::Colors;
use crate::config::{empty_response, Config};
use crate::env::Environment;

#[derive(Debug, Deserialize, Serialize)]
pub struct BookmarkConfig {
  pub path: String,
  pub name: String,

  #[serde(skip_serializing_if = "Option::is_none")]
  pub recursive: Option<String>,
}

#[derive(Debug)]
pub struct Bookmark {
  pub id: String,
  pub path: String,
  pub name: String,
}

impl Bookmark {
  pub fn handle(command: Option<&str>, payload: &[&str]) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
    Ok(match command {
      Some("list") => Arc::new(Self::to_table(&Self::list_filtered(payload.first().copied())?)?.into_bytes()),
      Some("tsv") => Arc::new(Self::to_tsv(&Self::list_filtered(payload.first().copied())?).into_bytes()),
      Some("export") => Arc::new(
        Self::to_export(
          &Self::list_filtered(payload.first().copied())?,
          payload.get(1).copied().unwrap_or("B_"),
        )?
        .into_bytes(),
      ),
      Some("autocomplete") => {
        Arc::new(Self::to_autocomplete(&Self::list_filtered(payload.first().copied())?).into_bytes())
      }
      Some("names") => Arc::new(Self::to_names(&Self::list_filtered(payload.first().copied())?).into_bytes()),
      Some("show") => Arc::new(Self::show_current(payload.first().copied().unwrap_or(""))?.into_bytes()),
      Some("save") => {
        Self::save_current(
          payload.first().copied().unwrap_or(""),
          Bookmark::name_from_payload(payload),
        )?;
        empty_response()
      }
      Some("delete") => {
        Self::delete_current(payload.first().copied().unwrap_or(""))?;
        empty_response()
      }
      _ => return Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
    })
  }

  pub fn list(config: &Config) -> Result<Vec<Self>, Box<dyn Error>> {
    let mut bookmarks = Vec::new();

    for (id, bookmark) in &config.bookmarks {
      if let Some(recursive) = &bookmark.recursive {
        bookmarks.push(Self {
          id: format!("{recursive}-root"),
          path: bookmark.path.clone().replace("~", "$HOME"),
          name: format!("{}: Root", bookmark.name),
        });

        let root = PathBuf::from(&bookmark.path.replace("~", &std::env::var("HOME")?));
        if root.is_dir() {
          for entry in fs::read_dir(root)? {
            let entry = entry?;
            let file_type = entry.file_type()?;

            if !file_type.is_dir() {
              continue;
            }

            let folder = entry.file_name().to_string_lossy().into_owned();
            if folder.starts_with('.') {
              continue;
            }

            bookmarks.push(Self {
              id: format!("{recursive}-{folder}"),
              path: format!("{}/{folder}", bookmark.path).replace("~", "$HOME"),
              name: format!("{}: {folder}", bookmark.name),
            });
          }
        }
      } else {
        bookmarks.push(Self {
          id: id.clone(),
          path: bookmark.path.clone().replace("~", "$HOME"),
          name: bookmark.name.clone(),
        });
      }
    }

    bookmarks.sort_by(|left, right| (&left.id, &left.path, &left.name).cmp(&(&right.id, &right.path, &right.name)));

    Ok(bookmarks)
  }

  pub fn save(config: &mut Config, id: &str, name: Option<&str>) -> Result<(), Box<dyn Error>> {
    if id.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Please provide a bookmark name").into());
    }

    if !Regex::new(r"^(?:[a-z0-9-_.:@]+)$")?.is_match(id) {
      return Err(
        IoError::new(
          ErrorKind::InvalidInput,
          "Use only letters, numbers, and -, _, ., : and @ for the name",
        )
        .into(),
      );
    }

    if Self::list(config)?.iter().any(|bookmark| bookmark.id == id) {
      return Err(IoError::new(ErrorKind::AlreadyExists, format!("Bookmark {id} already exists")).into());
    }

    config.bookmarks.insert(
      id.to_string(),
      BookmarkConfig {
        path: Bookmark::collapse_home(&std::env::current_dir()?.to_string_lossy())?,
        name: name.filter(|name| !name.is_empty()).unwrap_or(id).to_string(),
        recursive: None,
      },
    );

    Ok(())
  }

  pub fn delete(config: &mut Config, id: &str) -> Result<(), Box<dyn Error>> {
    if id.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Please provide a bookmark name").into());
    }

    if config.bookmarks.remove(id).is_some() {
      Ok(())
    } else {
      Err(IoError::new(ErrorKind::NotFound, format!("Bookmark {id} does not exist")).into())
    }
  }

  pub fn to_tsv(bookmarks: &[Self]) -> String {
    let mut response = String::new();

    for bookmark in bookmarks {
      response.push_str(&bookmark.id);
      response.push('\t');
      response.push_str(&bookmark.path);
      response.push('\t');
      response.push_str(&bookmark.name);
      response.push('\n');
    }

    response
  }

  pub fn to_export(bookmarks: &[Self], prefix: &str) -> Result<String, Box<dyn Error>> {
    let mut response = String::new();

    for bookmark in bookmarks {
      response.push_str(prefix);
      response.push_str(&bookmark.id.replace('-', "_").to_uppercase());
      response.push('=');
      response.push_str(&Environment::quote_env_value(&Bookmark::expand_home(&bookmark.path)?));
      response.push('\n');
    }

    Ok(response)
  }

  pub fn to_autocomplete(bookmarks: &[Self]) -> String {
    let mut response = String::new();

    for bookmark in bookmarks {
      response.push_str(&bookmark.id);
      response.push('\t');
      response.push_str(&bookmark.path);
      response.push('\n');
    }

    response
  }

  pub fn to_names(bookmarks: &[Self]) -> String {
    let mut response = String::new();

    for bookmark in bookmarks {
      response.push_str(&bookmark.id);
      response.push('\n');
    }

    response
  }

  pub fn to_table(bookmarks: &[Self]) -> Result<String, Box<dyn Error>> {
    let colors = Colors::new(None)?;

    let color_reset = "\x1b[0m";
    let color_bold = "\x1b[1m";
    let color_success = colors.foreground(colors.palette.green);
    let color_primary = colors.foreground(colors.palette.primary);
    let color_secondary = colors.foreground(colors.palette.secondary);
    let mut table = Table::new();
    table
      .set_style(TableComponent::LeftBorder, '│')
      .set_style(TableComponent::RightBorder, '│')
      .set_style(TableComponent::TopBorder, '─')
      .set_style(TableComponent::BottomBorder, '─')
      .set_style(TableComponent::LeftHeaderIntersection, '├')
      .set_style(TableComponent::HeaderLines, '─')
      .set_style(TableComponent::MiddleHeaderIntersections, '┼')
      .set_style(TableComponent::RightHeaderIntersection, '┤')
      .set_style(TableComponent::VerticalLines, '│')
      .set_style(TableComponent::HorizontalLines, '─')
      .set_style(TableComponent::MiddleIntersections, '┼')
      .set_style(TableComponent::LeftBorderIntersections, '├')
      .set_style(TableComponent::RightBorderIntersections, '┤')
      .set_style(TableComponent::TopBorderIntersections, '┬')
      .set_style(TableComponent::BottomBorderIntersections, '┴')
      .set_style(TableComponent::TopLeftCorner, '┌')
      .set_style(TableComponent::TopRightCorner, '┐')
      .set_style(TableComponent::BottomLeftCorner, '└')
      .set_style(TableComponent::BottomRightCorner, '┘')
      .remove_style(TableComponent::HorizontalLines)
      .remove_style(TableComponent::MiddleIntersections)
      .remove_style(TableComponent::LeftBorderIntersections)
      .remove_style(TableComponent::RightBorderIntersections);

    table.set_header(vec![Cell::new("ID"), Cell::new("Destination"), Cell::new("Name")]);

    for bookmark in bookmarks {
      table.add_row(vec![
        Cell::new(format!("{color_success}{color_bold}{}{color_reset}", bookmark.id)),
        Cell::new(
          bookmark
            .path
            .replace("$HOME", &format!("{color_primary}$HOME{color_reset}")),
        ),
        Cell::new(format!("{color_secondary}{}{color_reset}", bookmark.name)),
      ]);
    }

    Ok(table.to_string())
  }

  pub fn expand_home(path: &str) -> Result<String, Box<dyn Error>> {
    let home = std::env::var("HOME")?;

    if path == "~" || path == "$HOME" {
      Ok(home)
    } else if let Some(rest) = path.strip_prefix("~/") {
      Ok(format!("{home}/{rest}"))
    } else if let Some(rest) = path.strip_prefix("$HOME/") {
      Ok(format!("{home}/{rest}"))
    } else {
      Ok(path.to_string())
    }
  }

  pub fn collapse_home(path: &str) -> Result<String, Box<dyn Error>> {
    let home = std::env::var("HOME")?;

    if path == home {
      Ok("~".to_string())
    } else if let Some(rest) = path.strip_prefix(&format!("{home}/")) {
      Ok(format!("~/{rest}"))
    } else {
      Ok(path.to_string())
    }
  }

  fn list_filtered(query: Option<&str>) -> Result<Vec<Self>, Box<dyn Error>> {
    let mut bookmarks = Self::list(&Config::load_current()?)?;

    if let Some(query) = query.filter(|query| !query.is_empty()) {
      let query = Regex::new(&format!("(?:{query})"))?;
      bookmarks.retain(|bookmark| query.is_match(&bookmark.id));
    }

    Ok(bookmarks)
  }

  fn show_current(id: &str) -> Result<String, Box<dyn Error>> {
    if id.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Please provide a bookmark name").into());
    }

    for bookmark in Self::list(&Config::load_current()?)? {
      if bookmark.id == id {
        return Self::expand_home(&bookmark.path);
      }
    }

    Err(IoError::new(ErrorKind::NotFound, format!("Bookmark {id} does not exist")).into())
  }

  fn save_current(id: &str, name: Option<String>) -> Result<(), Box<dyn Error>> {
    let path = Config::current_path()?;
    let mut config = Config::load(Path::new(&path))?;

    Self::save(&mut config, id, name.as_deref())?;
    config.save(Path::new(&path))
  }

  fn delete_current(id: &str) -> Result<(), Box<dyn Error>> {
    let path = Config::current_path()?;
    let mut config = Config::load(Path::new(&path))?;

    Self::delete(&mut config, id)?;
    config.save(Path::new(&path))
  }

  fn name_from_payload(payload: &[&str]) -> Option<String> {
    if payload.len() > 1 {
      Some(payload[1..].join(" "))
    } else {
      None
    }
  }
}
