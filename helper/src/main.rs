mod agents;
mod application;
mod bookmarks;
mod cli;
mod colors;
mod completions;
mod config;
mod defaults;
mod env;
mod git;
mod node;
mod prompt;
mod protocol;
mod select;
mod ssh;
mod tmux;

use crate::agents::*;
use crate::application::*;
use crate::bookmarks::*;
use crate::cli::*;
use crate::colors::*;
use crate::completions::*;
use crate::config::*;
use crate::env::*;
use crate::git::*;
use crate::node::*;
use crate::prompt::*;
use crate::protocol::*;
use crate::select::*;
use crate::ssh::*;
use crate::tmux::*;
use clap::Parser;
use std::backtrace::Backtrace;
use std::error::Error;
use std::io::{Error as IoError, ErrorKind};
use std::panic;
use std::path::Path;
use std::process::id;
use std::sync::Arc;
use std::sync::mpsc::Sender;
use std::time::Duration;

fn install_error_handler() {
  panic::set_hook(Box::new(|panic| {
    eprintln!("Fishamnium aborted: {panic}");
    eprintln!("Backtrace:\n{}", Backtrace::force_capture());
  }));
}

fn abort(error: Box<dyn Error>) -> ! {
  eprintln!("Fishamnium aborted: {error}");

  let mut source = error.source();
  while let Some(error) = source {
    eprintln!("Caused by: {error}");
    source = error.source();
  }

  eprintln!("Backtrace:\n{}", Backtrace::force_capture());
  std::process::exit(1);
}

fn quit(events: Arc<Sender<ApplicationSignal>>) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
  std::thread::spawn(move || {
    std::thread::sleep(Duration::from_millis(100));
    let _ = events.send(ApplicationSignal::Terminate);
  });

  Ok(empty_response())
}

fn dispatch_request(request: Vec<u8>, events: Arc<Sender<ApplicationSignal>>) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
  let arguments = decode_request(&request)?;

  let [request, payload @ ..] = arguments.as_slice() else {
    return Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into());
  };

  let first_arg = payload.first().map(String::as_str);
  let second_arg = payload.get(1).map(String::as_str);
  let command_arguments = payload.get(1..).unwrap_or(&[]);
  let command_arguments = command_arguments.iter().map(String::as_str).collect::<Vec<_>>();

  match request.as_str() {
    "pid" => Ok(Arc::new(format!("{}", id()).into_bytes())),
    "env" => Ok(Arc::new(Environment::new()?.to_response(first_arg)?)),
    "shell-environment" => Ok(Arc::new(Environment::to_shell_response(first_arg, second_arg)?)),
    "colors" => Ok(Arc::new(Colors::new(first_arg)?.to_response())),
    "vscode-theme" => Ok(Arc::new(Colors::for_theme(first_arg)?.vscode_theme()?.into_bytes())),
    "completions" => Ok(Arc::new(Completions::to_fish_response(payload)?)),
    "configuration-file" => Ok(Arc::new(Config::current_path()?.into_bytes())),
    "config" | "configuration" => {
      if first_arg == Some("format") {
        if payload.len() != 2 {
          return Err(IoError::new(ErrorKind::InvalidInput, "Config format accepts exactly one config path").into());
        }

        let path = Path::new(&payload[1]);
        if !path.is_file() {
          return Err(
            IoError::new(
              ErrorKind::NotFound,
              format!("Config file {} does not exist", path.display()),
            )
            .into(),
          );
        }

        return Ok(Arc::new(serde_yaml::to_string(&Config::load(path)?)?.into_bytes()));
      }

      if payload.len() > 2 {
        return Err(IoError::new(ErrorKind::InvalidInput, "Config accepts at most one fallback argument").into());
      }

      let fallback = second_arg.into_iter().collect::<Vec<_>>();
      Ok(Arc::new(
        Config::load_current()?.get(first_arg, &fallback)?.into_bytes(),
      ))
    }
    "agents" => Agents::handle(first_arg, &command_arguments),
    "bookmarks" => Bookmark::handle(first_arg, &command_arguments),
    "git" => Git::handle(first_arg, &command_arguments),
    "node" => Node::handle(first_arg, &command_arguments),
    "prompt" => Prompt::handle(&payload.iter().map(String::as_str).collect::<Vec<_>>()),
    "ssh" => Ok(Arc::new(Ssh::handle(first_arg, &command_arguments)?)),
    "tmux" => Ok(Arc::new(Tmux::handle(first_arg, &command_arguments)?)),
    "exit" | "quit" => quit(events.clone()),
    _ => Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
  }
}

fn handle_request(request: Vec<u8>, events: Arc<Sender<ApplicationSignal>>) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
  let response = dispatch_request(request, events);

  match response {
    Ok(message) if message.is_empty() => Ok(Arc::new(encode_response(None)?)),
    Ok(message) => Ok(Arc::new(encode_response(Some(message.as_ref()))?)),
    Err(error) => Ok(Arc::new(encode_error(&format!(
      "{error}\nBacktrace:\n{}",
      Backtrace::force_capture()
    ))?)),
  }
}

fn handle_client_response(response: &[u8]) -> ! {
  match decode_response(response) {
    Ok(Response::Ok(message)) => {
      if let Some(message) = message.filter(|message| !message.is_empty()) {
        println!("{}", String::from_utf8_lossy(&message));
      }

      std::process::exit(0);
    }
    Ok(Response::Error(message)) => {
      if !message.is_empty() {
        println!("{message}");
      }

      std::process::exit(1);
    }
    Err(error) => {
      println!("Invalid response encoding: {error}");
      std::process::exit(1);
    }
  }
}

fn dispatch_local_command(command: Option<&str>, payload: &[String]) -> Result<Option<Vec<u8>>, Box<dyn Error>> {
  let first_arg = payload.first().map(String::as_str);
  let command_arguments = payload
    .get(1..)
    .unwrap_or(&[])
    .iter()
    .map(String::as_str)
    .collect::<Vec<_>>();

  Ok(match command {
    Some("select") => Some(Select::from_stdin(payload)?.into_bytes()),
    Some("agents") => Some(Agents::handle(first_arg, &command_arguments)?.as_ref().clone()),
    Some("git") => Some(Git::handle(first_arg, &command_arguments)?.as_ref().clone()),
    Some("node") => Some(Node::handle(first_arg, &command_arguments)?.as_ref().clone()),
    Some("prompt") => Some(
      Prompt::handle(&payload.iter().map(String::as_str).collect::<Vec<_>>())?
        .as_ref()
        .clone(),
    ),
    Some("ssh") => Some(Ssh::handle(first_arg, &command_arguments)?),
    Some("completions") => Some(Completions::to_fish_response(payload)?),
    _ => None,
  })
}

fn run() -> Result<(), Box<dyn Error>> {
  let arguments = Arguments::parse();
  let reload = arguments.command.as_deref() == Some("reload");

  if arguments.client.is_none() && !reload {
    if let Some(response) = dispatch_local_command(arguments.command.as_deref(), &arguments.payload)? {
      print!("{}", String::from_utf8_lossy(&response));
      return Ok(());
    }
  }

  let application = Application::new("fishamnium", 40_000, Some(handle_request))?;

  if reload && arguments.client.is_some() {
    return Err(IoError::new(ErrorKind::InvalidInput, "Reload cannot be used with --client").into());
  }

  if arguments.server {
    application.run_server()?;
    std::process::exit(0);
  } else if arguments.client.is_none() {
    if reload {
      application.kill_server()?;
    }

    application.boot()?;

    if reload {
      return Ok(());
    }
  }

  if let Some(command) = arguments.command {
    let mut request = vec![command];
    request.extend(arguments.payload);
    let request = encode_request(&request)?;
    let response = application.send(arguments.client.as_deref(), &request)?;
    handle_client_response(&response);
  }

  Ok(())
}

fn main() {
  install_error_handler();

  if let Err(error) = run() {
    abort(error);
  }
}
