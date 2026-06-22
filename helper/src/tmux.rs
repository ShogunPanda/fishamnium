use std::collections::HashMap;
use std::error::Error;
use std::io::{Error as IoError, ErrorKind};
use std::process::Command;

const NATO_NAMES: [&str; 26] = [
  "alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "juliett", "kilo", "lima", "mike",
  "november", "oscar", "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey", "xray", "yankee",
  "zulu",
];

pub struct Tmux;

impl Tmux {
  pub fn handle(command: Option<&str>, payload: &[&str]) -> Result<Vec<u8>, Box<dyn Error>> {
    match command {
      Some("next-session") => Self::next_session(payload),
      _ => Err(IoError::new(ErrorKind::InvalidInput, "Unknown tmux command").into()),
    }
  }

  fn next_session(payload: &[&str]) -> Result<Vec<u8>, Box<dyn Error>> {
    if !payload.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Tmux next-session does not accept arguments").into());
    }

    let sessions = Self::sessions()?;

    for name in NATO_NAMES {
      match sessions.get(name) {
        Some(attached) if *attached > 0 => {}
        _ => return Ok(name.as_bytes().to_vec()),
      }
    }

    Ok(b"zulu".to_vec())
  }

  fn sessions() -> Result<HashMap<String, u64>, Box<dyn Error>> {
    let output = Command::new("tmux")
      .args(["list-sessions", "-F", "#{session_name}\t#{session_attached}"])
      .output()?;

    if !output.status.success() {
      return Ok(HashMap::new());
    }

    let mut sessions = HashMap::new();
    let output = String::from_utf8(output.stdout)?;

    for line in output.lines() {
      let Some((name, attached)) = line.split_once('\t') else {
        continue;
      };

      sessions.insert(name.to_string(), attached.parse()?);
    }

    Ok(sessions)
  }
}
