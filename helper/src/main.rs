mod application;
mod bookmarks;
mod cli;
mod colors;
mod config;
mod defaults;
mod env;

use crate::application::*;
use crate::bookmarks::*;
use crate::cli::*;
use crate::colors::*;
use crate::config::*;
use crate::env::*;
use clap::Parser;
use std::error::Error;
use std::io::{Error as IoError, ErrorKind};
use std::process::id;
use std::sync::Arc;
use std::sync::mpsc::Sender;
use std::time::Duration;

fn quit(events: Arc<Sender<ApplicationSignal>>) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
  std::thread::spawn(move || {
    std::thread::sleep(Duration::from_millis(100));
    let _ = events.send(ApplicationSignal::Terminate);
  });

  Ok(empty_response())
}

fn handle_request(request: Vec<u8>, events: Arc<Sender<ApplicationSignal>>) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
  let response: Result<Arc<Vec<u8>>, Box<dyn Error>> = match std::str::from_utf8(&request) {
    Ok(request) => {
      if let [request, payload @ ..] = request.split(" ").collect::<Vec<_>>().as_slice() {
        let first_arg = payload.first().copied();
        let second_arg = payload.get(1).copied();
        let arguments = payload.get(1..).unwrap_or(&[]);

        match *request {
          "pid" => Ok(Arc::new(format!("{}", id()).into_bytes())),
          "env" => Ok(Arc::new(Environment::new()?.to_response(first_arg)?)),
          "shell-environment" => Ok(Arc::new(Environment::to_shell_response(first_arg, second_arg)?)),
          "colors" => Ok(Arc::new(Colors::new(first_arg)?.to_response())),
          "configuration-file" => Ok(Arc::new(Config::current_path()?.into_bytes())),
          "config" | "configuration" => Ok(Arc::new(
            Config::load_current()?.get(first_arg, arguments)?.into_bytes(),
          )),
          "bookmarks" => Bookmark::handle(first_arg, arguments),
          "exit" | "quit" => quit(events.clone()),
          _ => Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
        }
      } else {
        Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into())
      }
    }
    Err(_) => Err(IoError::new(ErrorKind::InvalidInput, "Invalid request encoding").into()),
  };

  match response {
    Ok(message) if message.is_empty() => Ok(empty_ok_response()),
    Ok(message) => {
      let mut framed = b"0\n".to_vec();
      framed.extend(message.as_ref());
      Ok(Arc::new(framed))
    }
    Err(error) => Ok(Arc::new(format!("1 {error}").into_bytes())),
  }
}

fn handle_client_response(response: &[u8]) -> ! {
  let response = String::from_utf8_lossy(response);
  let response = response.trim();
  let (code, message) = if let Some((code, message)) = response.split_once('\n') {
    (code.trim(), message.trim())
  } else if let Some((code, message)) = response.split_once(' ') {
    (code.trim(), message.trim())
  } else {
    (response, "")
  };
  let code = code.parse::<i32>().unwrap_or(1);

  if !message.is_empty() {
    println!("{message}");
  }

  std::process::exit(code);
}

fn main() -> Result<(), Box<dyn Error>> {
  let arguments = Arguments::parse();
  let application = Application::new("fishamnium", 40_000, Some(handle_request))?;

  if arguments.server {
    application.run_server()?;
    std::process::exit(0);
  } else if arguments.client.is_none() {
    application.boot()?;
  }

  if let Some(command) = arguments.command {
    let request = if arguments.payload.is_empty() {
      command
    } else {
      format!("{} {}", command, arguments.payload.join(" "))
    };
    let response = application.send(arguments.client.as_deref(), request.as_bytes())?;
    handle_client_response(&response);
  }

  Ok(())
}
