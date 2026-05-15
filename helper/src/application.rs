use std::env;
use std::fs::{self, DirBuilder, File, OpenOptions};
use std::io::{Error, ErrorKind, Read, Result, Write};
use std::net::{TcpListener, TcpStream};
use std::os::fd::AsRawFd;
use std::os::unix::fs::{DirBuilderExt, FileTypeExt, MetadataExt};
use std::os::unix::net::{UnixListener, UnixStream};
use std::path::PathBuf;
use std::process::{self, Command};
use std::sync::mpsc::{Receiver, Sender};
use std::sync::{Arc, mpsc};
use std::thread;
use std::time::{Duration, Instant};

use nix::unistd::{ForkResult, Uid, dup2, fork, setsid};
use threadpool::ThreadPool;

use crate::config::empty_response;

const CONNECT_TIMEOUT: Duration = Duration::from_secs(2);
const CONNECT_RETRY_DELAY: Duration = Duration::from_millis(30);
const STATE_DIR_MODE: u32 = 0o700;
const WRITABLE_BY_GROUP_OR_OTHER: u32 = 0o022;
const WORKER_THREADS: usize = 16;
const FRAME_HEADER_SIZE: usize = 2;
const MAX_FRAME_SIZE: usize = u16::MAX as usize;

type Handler = Arc<
  dyn Fn(Vec<u8>, Arc<Sender<ApplicationSignal>>) -> std::result::Result<Arc<Vec<u8>>, Box<dyn std::error::Error>>
    + Send
    + Sync
    + 'static,
>;

pub enum ApplicationSignal {
  Terminate,
}

pub struct Application {
  uid: u32,
  state_dir: PathBuf,
  socket_path: PathBuf,
  log_path: PathBuf,
  pid_path: PathBuf,
  port: u16,
  handler: Handler,
  sender: Arc<Sender<ApplicationSignal>>,
  receiver: Receiver<ApplicationSignal>,
}

impl Application {
  pub fn new<F>(base_name: impl Into<String>, base_port: u32, handler: Option<F>) -> Result<Self>
  where
    F: Fn(Vec<u8>, Arc<Sender<ApplicationSignal>>) -> std::result::Result<Arc<Vec<u8>>, Box<dyn std::error::Error>>
      + Send
      + Sync
      + 'static,
  {
    let base_name = base_name.into();
    let state_dir = match env::var_os("XDG_STATE_HOME") {
      Some(xdg_state_home) => PathBuf::from(xdg_state_home).join(&base_name),
      None => PathBuf::from(
        env::var_os("HOME")
          .ok_or_else(|| Error::new(ErrorKind::NotFound, "HOME is not set and XDG_STATE_HOME is not set"))?,
      )
      .join(".local")
      .join("state")
      .join(&base_name),
    };

    let uid = Uid::effective().as_raw();
    let port = base_port.checked_add(uid).ok_or_else(|| {
      Error::new(
        ErrorKind::InvalidInput,
        format!("Effective uid {uid} is too large for port calculation"),
      )
    })?;

    if port > u16::MAX.into() {
      return Err(Error::new(
        ErrorKind::InvalidInput,
        format!("Base port {base_port} + effective uid {uid} exceeds port 65535"),
      ));
    }

    let (sender, receiver) = mpsc::channel::<ApplicationSignal>();

    Ok(Self {
      uid,
      socket_path: state_dir.join("server.sock"),
      log_path: state_dir.join("server.log"),
      pid_path: state_dir.join("server.pid"),
      state_dir,
      port: port as u16,
      handler: handler.map_or_else(
        || Arc::new(|_1, _2| Ok(empty_response())) as Handler,
        |handler| Arc::new(handler),
      ),
      sender: Arc::new(sender),
      receiver,
    })
  }

  #[allow(unused)]
  pub fn set_handler<F>(&mut self, handler: F)
  where
    F: Fn(Vec<u8>, Arc<Sender<ApplicationSignal>>) -> std::result::Result<Arc<Vec<u8>>, Box<dyn std::error::Error>>
      + Send
      + Sync
      + 'static,
  {
    self.handler = Arc::new(handler);
  }

  pub fn send(&self, address: Option<&str>, message: &[u8]) -> Result<Vec<u8>> {
    match address {
      Some(address) => {
        let mut stream = TcpStream::connect(address)?;
        Application::write(&mut stream, message)?;
        Application::read(&mut stream)
      }
      None => {
        let mut stream = UnixStream::connect(&self.socket_path)?;
        Application::write(&mut stream, message)?;
        Application::read(&mut stream)
      }
    }
  }

  pub fn boot(&self) -> Result<()> {
    self.ensure_state_dir()?;

    if UnixStream::connect(&self.socket_path).is_ok() {
      return Ok(());
    }

    Command::new(env::current_exe()?).arg("--server").spawn()?;
    self.connect_with_retry()?;

    Ok(())
  }

  pub fn run_server(&self) -> Result<()> {
    self.ensure_state_dir()?;

    // Daemonize the server
    match unsafe { fork() }.map_err(Error::other)? {
      ForkResult::Parent { .. } => process::exit(0),
      ForkResult::Child => {}
    }

    setsid().map_err(Error::other)?;

    match unsafe { fork() }.map_err(Error::other)? {
      ForkResult::Parent { .. } => process::exit(0),
      ForkResult::Child => {}
    }

    // Redirect STDIO
    let stdin = File::open("/dev/null")?;
    let stdout = OpenOptions::new().create(true).append(true).open(&self.log_path)?;

    dup2(stdin.as_raw_fd(), 0).map_err(Error::other)?;
    dup2(stdout.as_raw_fd(), 1).map_err(Error::other)?;
    dup2(stdout.as_raw_fd(), 2).map_err(Error::other)?;

    // Ensure state directory
    self.ensure_state_dir()?;

    if !self.cleanup_stale_socket()? {
      return Ok(());
    }

    if self.listen()? {
      match self.receiver.recv() {
        Ok(ApplicationSignal::Terminate) | Err(_) => {
          let _ = fs::remove_file(&self.pid_path);
          let _ = fs::remove_file(&self.socket_path);
          process::exit(0);
        }
      }
    }

    Ok(())
  }

  fn listen(&self) -> Result<bool> {
    // Open UNIX socket
    let unix_listener = match UnixListener::bind(&self.socket_path) {
      Ok(listener) => listener,
      // Race condition handling - If the address is already in use, check if it is active, it means another instance beated us.
      Err(error) if error.kind() == ErrorKind::AddrInUse => {
        if UnixStream::connect(&self.socket_path).is_ok() {
          return Ok(false);
        }

        return Err(error);
      }
      Err(error) => return Err(error),
    };

    // Open TCP socket
    let tcp_listener = match TcpListener::bind(("0.0.0.0", self.port)) {
      Ok(listener) => listener,
      Err(error) => {
        let _ = fs::remove_file(&self.socket_path);
        return Err(error);
      }
    };

    // Write PID file
    if let Err(error) = fs::write(&self.pid_path, format!("{}\n", process::id())) {
      let _ = fs::remove_file(&self.socket_path);
      return Err(error);
    }

    // Handle requests
    let pool = Arc::new(ThreadPool::new(WORKER_THREADS));

    let unix_handler = Arc::clone(&self.handler);
    let unix_pool = Arc::clone(&pool);
    let unix_sender = Arc::clone(&self.sender);
    thread::spawn(move || {
      for connection in unix_listener.incoming() {
        match connection {
          Ok(mut stream) => {
            let unix_handler = Arc::clone(&unix_handler);
            let unix_sender = Arc::clone(&unix_sender);
            unix_pool
              .execute(move || Application::handle_connection(&mut stream, unix_handler, unix_sender, "UNIX socket"));
          }
          Err(error) => eprintln!("Unix socket accept failed: {error}"),
        }
      }
    });

    let tcp_handler = Arc::clone(&self.handler);
    let tcp_pool = Arc::clone(&pool);
    let tcp_sender = Arc::clone(&self.sender);
    thread::spawn(move || {
      for connection in tcp_listener.incoming() {
        match connection {
          Ok(mut stream) => {
            let tcp_handler = Arc::clone(&tcp_handler);
            let tcp_sender = Arc::clone(&tcp_sender);
            tcp_pool.execute(move || Application::handle_connection(&mut stream, tcp_handler, tcp_sender, "TCP"));
          }
          Err(error) => eprintln!("TCP accept failed: {error}"),
        }
      }
    });

    Ok(true)
  }

  fn ensure_state_dir(&self) -> Result<()> {
    match fs::symlink_metadata(&self.state_dir) {
      Ok(metadata) => {
        if !metadata.file_type().is_dir() {
          return Err(Error::new(
            ErrorKind::AlreadyExists,
            format!("Path {} exists but is not a directory", self.state_dir.display()),
          ));
        }

        if metadata.uid() != self.uid {
          return Err(Error::new(
            ErrorKind::PermissionDenied,
            format!(
              "Path {} is not owned by effective uid {}",
              self.state_dir.display(),
              self.uid
            ),
          ));
        }

        if metadata.mode() & WRITABLE_BY_GROUP_OR_OTHER != 0 {
          return Err(Error::new(
            ErrorKind::PermissionDenied,
            format!("Path {} is group/world writable", self.state_dir.display()),
          ));
        }
      }
      Err(error) if error.kind() == ErrorKind::NotFound => {
        DirBuilder::new()
          .recursive(true)
          .mode(STATE_DIR_MODE)
          .create(&self.state_dir)?;
      }
      Err(error) => return Err(error),
    }

    Ok(())
  }

  fn cleanup_stale_socket(&self) -> Result<bool> {
    match fs::symlink_metadata(&self.socket_path) {
      Ok(metadata) => {
        if UnixStream::connect(&self.socket_path).is_ok() {
          return Ok(false);
        }

        if metadata.file_type().is_socket() {
          fs::remove_file(&self.socket_path)?;
          Ok(true)
        } else {
          Err(Error::new(
            ErrorKind::AlreadyExists,
            format!("Path {} exists but is not a Unix socket", self.socket_path.display()),
          ))
        }
      }
      Err(error) if error.kind() == ErrorKind::NotFound => Ok(true),
      Err(error) => Err(error),
    }
  }

  fn connect_with_retry(&self) -> Result<UnixStream> {
    let started_at = Instant::now();
    let mut last_error = None;

    while started_at.elapsed() < CONNECT_TIMEOUT {
      match UnixStream::connect(&self.socket_path) {
        Ok(stream) => return Ok(stream),
        Err(error) => last_error = Some(error),
      }

      thread::sleep(CONNECT_RETRY_DELAY);
    }

    Err(last_error.unwrap_or_else(|| Error::new(ErrorKind::TimedOut, "Server did not become available before timeout")))
  }

  fn handle_connection(
    stream: &mut (impl Read + Write),
    handler: Handler,
    sender: Arc<Sender<ApplicationSignal>>,
    transport: &str,
  ) {
    let request = match Application::read(stream) {
      Ok(request) => request,
      Err(error) => {
        eprintln!("{transport} read failed: {error}");
        return;
      }
    };

    match handler(request, sender).and_then(|response| Ok(Application::write(stream, response.as_ref())?)) {
      Ok(()) => {}
      Err(error) => eprintln!("{transport} handler failed: {error}"),
    }
  }

  fn read(stream: &mut impl Read) -> Result<Vec<u8>> {
    let mut header = [0; FRAME_HEADER_SIZE];
    stream.read_exact(&mut header)?;

    let payload_len = u16::from_be_bytes(header) as usize;
    let mut payload = vec![0; payload_len];
    stream.read_exact(&mut payload)?;

    Ok(payload)
  }

  fn write(stream: &mut impl Write, payload: &[u8]) -> Result<()> {
    if payload.len() > MAX_FRAME_SIZE {
      return Err(Error::new(
        ErrorKind::InvalidInput,
        format!("Payload length {} exceeds maximum {MAX_FRAME_SIZE}", payload.len()),
      ));
    }

    stream.write_all(&(payload.len() as u16).to_be_bytes())?;
    stream.write_all(payload)
  }
}
