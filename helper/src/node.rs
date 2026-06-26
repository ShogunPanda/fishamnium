use serde_json::Value as JsonValue;
use std::error::Error;
use std::fs;
use std::io::{Error as IoError, ErrorKind};
use std::sync::Arc;

pub struct Node;

impl Node {
  pub fn handle(command: Option<&str>, payload: &[&str]) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
    Ok(match command {
      Some("scripts") => {
        if payload.len() > 1 {
          return Err(IoError::new(ErrorKind::InvalidInput, "Node scripts accepts at most one package path").into());
        }

        Arc::new(Self::scripts(payload.first().copied().unwrap_or("package.json"))?.into_bytes())
      }
      _ => return Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
    })
  }

  fn scripts(path: &str) -> Result<String, Box<dyn Error>> {
    let package = serde_json::from_str::<JsonValue>(&fs::read_to_string(path)?)?;
    let Some(scripts) = package.get("scripts").and_then(JsonValue::as_object) else {
      return Err(IoError::new(ErrorKind::NotFound, "No scripts found").into());
    };
    let mut scripts = scripts.keys().collect::<Vec<_>>();
    scripts.sort();

    Ok(scripts.into_iter().map(|script| format!("{script}\n")).collect())
  }
}
