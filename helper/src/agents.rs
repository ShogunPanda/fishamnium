use rusqlite::Connection;
use std::error::Error;
use std::io::{Error as IoError, ErrorKind};
use std::path::PathBuf;
use std::sync::Arc;

pub struct Agents;

struct OpencodeSession {
  id: String,
  directory: String,
  title: String,
}

impl Agents {
  pub fn handle(command: Option<&str>, payload: &[&str]) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
    Ok(match command {
      Some("opencode") => Self::handle_opencode(payload)?,
      _ => return Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
    })
  }

  fn handle_opencode(payload: &[&str]) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
    Ok(match payload.first().copied() {
      Some("list") => {
        if payload.len() > 2 {
          return Err(IoError::new(ErrorKind::InvalidInput, "OpenCode list accepts at most one folder").into());
        }

        Arc::new(Self::opencode_sessions_tsv(payload.get(1).copied())?.into_bytes())
      }
      Some("last") => {
        if payload.len() > 2 {
          return Err(IoError::new(ErrorKind::InvalidInput, "OpenCode last accepts at most one folder").into());
        }

        Arc::new(Self::opencode_last(payload.get(1).copied())?.into_bytes())
      }
      _ => return Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
    })
  }

  fn opencode_last(folder: Option<&str>) -> Result<String, Box<dyn Error>> {
    let folder = folder.map(Self::absolute_path).transpose()?;
    let database = PathBuf::from(std::env::var("HOME")?).join(".local/share/opencode/opencode.db");
    let connection = Connection::open(database)?;
    let mut statement =
      connection.prepare("SELECT id, directory FROM session WHERE parent_id IS NULL ORDER BY time_updated DESC")?;
    let sessions = statement.query_map([], |row| Ok((row.get::<_, String>(0)?, row.get::<_, String>(1)?)))?;

    for session in sessions {
      let (id, directory) = session?;
      if folder.as_ref().is_none_or(|folder| {
        Self::absolute_path(&directory)
          .map(|directory| &directory == folder)
          .unwrap_or(false)
      }) {
        return Ok(format!("{id}\n"));
      }
    }

    Ok(String::new())
  }

  fn opencode_sessions_tsv(folder: Option<&str>) -> Result<String, Box<dyn Error>> {
    let folder = folder.map(Self::absolute_path).transpose()?;
    let database = PathBuf::from(std::env::var("HOME")?).join(".local/share/opencode/opencode.db");
    let connection = Connection::open(database)?;
    let mut statement = connection
      .prepare("SELECT id, directory, title FROM session WHERE parent_id IS NULL ORDER BY directory, title, id")?;
    let sessions = statement.query_map([], |row| {
      Ok(OpencodeSession {
        id: row.get(0)?,
        directory: row.get::<_, Option<String>>(1)?.unwrap_or_default(),
        title: row.get::<_, Option<String>>(2)?.unwrap_or_default(),
      })
    })?;
    let mut response = String::new();

    for session in sessions {
      let session = session?;
      if folder.as_ref().is_some_and(|folder| {
        Self::absolute_path(&session.directory)
          .map(|directory| &directory != folder)
          .unwrap_or(true)
      }) {
        continue;
      }

      response.push_str(&session.id);
      response.push('\t');
      response.push_str(&Self::collapse_home(&session.directory)?);
      response.push('\t');
      response.push_str(&session.title);
      response.push('\n');
    }

    Ok(response)
  }

  fn collapse_home(path: &str) -> Result<String, Box<dyn Error>> {
    let home = std::env::var("HOME")?;

    if path == home {
      Ok("~".to_string())
    } else if let Some(rest) = path.strip_prefix(&format!("{home}/")) {
      Ok(format!("~/{rest}"))
    } else {
      Ok(path.to_string())
    }
  }

  fn absolute_path(path: &str) -> Result<PathBuf, Box<dyn Error>> {
    let home = std::env::var("HOME")?;
    let path = if path == "~" || path == "$HOME" {
      home
    } else if let Some(rest) = path.strip_prefix("~/") {
      format!("{home}/{rest}")
    } else if let Some(rest) = path.strip_prefix("$HOME/") {
      format!("{home}/{rest}")
    } else {
      path.to_string()
    };
    let path = PathBuf::from(path);

    if path.is_absolute() {
      Ok(path)
    } else {
      Ok(std::env::current_dir()?.join(path))
    }
  }
}
