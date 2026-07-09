use crate::colors::Colors;
use base64::{Engine as _, engine::general_purpose::STANDARD as BASE64};
use nix::unistd::gethostname;
use std::error::Error;
use std::io::Write;
use std::io::{Error as IoError, ErrorKind};
use std::os::unix::process::CommandExt;
use std::process::{Command, Stdio};

pub struct Ssh {
  user: String,
  host: String,
  path: String,
}

impl Ssh {
  const BEGIN_MARKER: &str = "-----BEGIN FISHAMNIUM SSH-----";
  const END_MARKER: &str = "-----END FISHAMNIUM SSH-----";

  pub fn handle(command: Option<&str>, payload: &[&str]) -> Result<Vec<u8>, Box<dyn Error>> {
    match command {
      Some("available") => Ssh::available(payload),
      Some("show") => Ssh::current(payload)?.show(),
      Some("connect") => Ssh::connect(payload),
      _ => Err(IoError::new(ErrorKind::InvalidInput, "Unknown ssh command").into()),
    }
  }

  fn available(payload: &[&str]) -> Result<Vec<u8>, Box<dyn Error>> {
    if !payload.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Ssh available does not accept arguments").into());
    }

    let Ok(clipboard) = Ssh::read_clipboard() else {
      std::process::exit(1);
    };

    if Ssh::markers_range(&clipboard).is_some() {
      Ok(Vec::new())
    } else {
      std::process::exit(1);
    }
  }

  fn current(payload: &[&str]) -> Result<Self, Box<dyn Error>> {
    if !payload.is_empty() {
      return Err(IoError::new(ErrorKind::InvalidInput, "Ssh show does not accept arguments").into());
    }

    let user = std::env::var("USER").or_else(|_| std::env::var("LOGNAME"))?;
    let hostname = gethostname()?.to_string_lossy().into_owned();
    let host = std::env::var("FISHAMNIUM_SSH_HOST").unwrap_or(hostname);
    let path = std::env::var("PWD").unwrap_or(std::env::current_dir()?.to_string_lossy().into_owned());

    Ok(Ssh { user, host, path })
  }

  fn show(&self) -> Result<Vec<u8>, Box<dyn Error>> {
    let location = format!(
      "{}\n{}\t{}\t{}\n{}",
      Ssh::BEGIN_MARKER,
      self.user,
      self.host,
      self.path,
      Ssh::END_MARKER
    );

    eprint!("\x1b]52;c;{}\x07", BASE64.encode(location.as_bytes()));

    Ok(location.into_bytes())
  }

  fn connect(_payload: &[&str]) -> Result<Vec<u8>, Box<dyn Error>> {
    let Ok(clipboard) = Ssh::read_clipboard() else {
      return Ssh::exec_fish();
    };

    let Some(ssh) = Ssh::from_marked_text(&clipboard)? else {
      return Ssh::exec_fish();
    };

    Ssh::clear_clipboard()?;
    ssh.print_status();
    ssh.exec()
  }

  fn exec(&self) -> Result<Vec<u8>, Box<dyn Error>> {
    let (target, port) = self.target()?;
    let quoted_path = format!("'{}'", self.path.replace('\'', "'\\''"));
    let remote_command = format!("cd -- {quoted_path} && exec \"$SHELL\" -l");
    let mut command = Command::new("ssh");

    if let Some(port) = port {
      command.args(["-p", &port]);
    }

    Err(command.args(["-t", &target, &remote_command]).exec().into())
  }

  fn print_status(&self) {
    if let Ok(colors) = Colors::new(None) {
      eprintln!(
        "{}{}--> ssh {}@{} {}{}",
        "\x1b[1m",
        colors.foreground(&colors.palette.primary),
        self.user,
        self.host,
        self.path,
        "\x1b[0m"
      );
    } else {
      eprintln!("--> ssh {}@{} {}", self.user, self.host, self.path);
    }
  }

  fn from_marked_text(text: &str) -> Result<Option<Self>, Box<dyn Error>> {
    let Some((start, end)) = Ssh::markers_range(text) else {
      return Ok(None);
    };

    let location = text[start..end].trim_matches(['\r', '\n']);
    let fields = location.split('\t').collect::<Vec<_>>();
    if fields.len() != 3 {
      return Err(IoError::new(ErrorKind::InvalidInput, "SSH location must be user<TAB>host<TAB>path").into());
    }

    Ok(Some(Ssh::from_fields(fields[0], fields[1], fields[2])?))
  }

  fn from_fields(user: &str, host: &str, path: &str) -> Result<Self, Box<dyn Error>> {
    for (name, value) in [("user", user), ("host", host), ("path", path)] {
      if value.is_empty() {
        return Err(IoError::new(ErrorKind::InvalidInput, format!("SSH location has an empty {name}")).into());
      }

      if value.contains('\t') || value.contains('\n') || value.contains('\r') {
        return Err(IoError::new(ErrorKind::InvalidInput, format!("SSH location has an invalid {name}")).into());
      }
    }

    Ok(Ssh {
      user: user.to_string(),
      host: host.to_string(),
      path: path.to_string(),
    })
  }

  fn target(&self) -> Result<(String, Option<String>), Box<dyn Error>> {
    if self.host.starts_with('[') {
      let Some(end) = self.host.find(']') else {
        return Err(IoError::new(ErrorKind::InvalidInput, "SSH location has an invalid IPv6 host").into());
      };

      let address = &self.host[1..end];
      let rest = &self.host[end + 1..];

      if rest.is_empty() {
        return Ok((format!("{}@{address}", self.user), None));
      }

      let Some(port) = rest
        .strip_prefix(':')
        .filter(|port| !port.is_empty() && port.chars().all(|c| c.is_ascii_digit()))
      else {
        return Err(IoError::new(ErrorKind::InvalidInput, "SSH location has an invalid port").into());
      };

      return Ok((format!("{}@{address}", self.user), Some(port.to_string())));
    }

    match self.host.rsplit_once(':') {
      Some((host, port)) if !host.contains(':') && !port.is_empty() && port.chars().all(|c| c.is_ascii_digit()) => {
        Ok((format!("{}@{host}", self.user), Some(port.to_string())))
      }
      _ => Ok((format!("{}@{}", self.user, self.host), None)),
    }
  }

  fn markers_range(text: &str) -> Option<(usize, usize)> {
    let start = text.find(Ssh::BEGIN_MARKER)? + Ssh::BEGIN_MARKER.len();
    let end = text[start..].find(Ssh::END_MARKER)? + start;

    (start < end).then_some((start, end))
  }

  fn exec_fish() -> Result<Vec<u8>, Box<dyn Error>> {
    let mut shells = vec!["fish".to_string()];

    if let Ok(shell) = std::env::var("SHELL")
      && shell.ends_with("/fish")
    {
      shells.insert(0, shell);
    }

    for shell in [
      "/opt/homebrew/bin/fish",
      "/usr/local/bin/fish",
      "/opt/local/bin/fish",
      "/usr/bin/fish",
      "/bin/fish",
    ] {
      shells.push(shell.to_string());
    }

    for shell in shells {
      let error = Command::new(&shell).exec();

      if error.kind() != ErrorKind::NotFound {
        return Err(error.into());
      }
    }

    Err(IoError::new(ErrorKind::NotFound, "fish shell not found").into())
  }

  fn read_clipboard() -> Result<String, Box<dyn Error>> {
    for (program, args) in [
      ("pbpaste", &[][..]),
      ("wl-paste", &["--no-newline"][..]),
      ("xclip", &["-selection", "clipboard", "-out"][..]),
      ("xsel", &["--clipboard", "--output"][..]),
    ] {
      let Ok(output) = Command::new(program).args(args).output() else {
        continue;
      };

      if output.status.success() {
        return Ok(String::from_utf8(output.stdout)?);
      }
    }

    Err(IoError::new(ErrorKind::NotFound, "No supported clipboard reader found").into())
  }

  fn clear_clipboard() -> Result<(), Box<dyn Error>> {
    for (program, args) in [
      ("pbcopy", &[][..]),
      ("wl-copy", &[][..]),
      ("xclip", &["-selection", "clipboard"][..]),
      ("xsel", &["--clipboard", "--input"][..]),
    ] {
      let Ok(mut child) = Command::new(program).args(args).stdin(Stdio::piped()).spawn() else {
        continue;
      };

      if let Some(stdin) = &mut child.stdin {
        stdin.write_all(b"")?;
      }

      if child.wait()?.success() {
        return Ok(());
      }
    }

    Err(IoError::new(ErrorKind::NotFound, "No supported clipboard writer found").into())
  }
}
