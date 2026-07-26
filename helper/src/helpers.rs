use std::env;
use std::error::Error;
use std::fs;
use std::io::{Error as IoError, ErrorKind};
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::sync::Arc;

use crate::application::Application;
use crate::protocol::{Response, decode_response};

pub struct Helpers;

impl Helpers {
  pub fn handle(command: &str, request: &[u8]) -> Result<Option<Arc<Vec<u8>>>, Box<dyn Error>> {
    let Some(path) = Self::path(command)? else {
      return Ok(None);
    };

    let mut child = Command::new(&path)
      .stdin(Stdio::piped())
      .stdout(Stdio::piped())
      .stderr(Stdio::inherit())
      .spawn()?;

    let mut stdin = child
      .stdin
      .take()
      .ok_or_else(|| IoError::other("Helper stdin is not available"))?;
    Application::write(&mut stdin, request)?;
    drop(stdin);

    let mut stdout = child
      .stdout
      .take()
      .ok_or_else(|| IoError::other("Helper stdout is not available"))?;
    let response = match decode_response(&Application::read(&mut stdout)?)? {
      Response::Ok(Some(response)) => response,
      Response::Ok(None) => Vec::new(),
      Response::Error(error) => return Err(IoError::other(error).into()),
    };
    child.wait()?;

    Ok(Some(Arc::new(response)))
  }

  fn path(command: &str) -> Result<Option<PathBuf>, Box<dyn Error>> {
    if command.is_empty()
      || !command
        .bytes()
        .all(|byte| byte.is_ascii_alphanumeric() || b"_-".contains(&byte))
    {
      return Ok(None);
    }

    let home = env::var_os("HOME").ok_or_else(|| IoError::new(ErrorKind::NotFound, "HOME is not set"))?;
    let path = PathBuf::from(home).join(".config/fishamnium/helpers").join(command);

    match fs::metadata(&path) {
      Ok(metadata) if metadata.is_file() => Ok(Some(path)),
      Ok(_) => Err(
        IoError::new(
          ErrorKind::InvalidInput,
          format!("Helper {} is not a regular file", path.display()),
        )
        .into(),
      ),
      Err(error) if error.kind() == ErrorKind::NotFound => Ok(None),
      Err(error) => Err(error.into()),
    }
  }
}
