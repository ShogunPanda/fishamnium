use git2::{BranchType, Repository};
use serde_json::{Map, Value};
use std::collections::BTreeMap;
use std::error::Error;
use std::io::{Error as IoError, ErrorKind};
use std::path::Path;
use std::sync::Arc;

pub struct Git;

impl Git {
  pub fn handle(command: Option<&str>, payload: &[&str]) -> Result<Arc<Vec<u8>>, Box<dyn Error>> {
    Ok(match command {
      Some("is-repository") => Arc::new(Self::is_repository()?.into_bytes()),
      Some("branch-name") => Arc::new(Self::current_branch_name(false)?.into_bytes()),
      Some("full-branch-name") => Arc::new(Self::current_branch_name(true)?.into_bytes()),
      Some("sha") => Arc::new(Self::sha(7)?.into_bytes()),
      Some("full-sha") => Arc::new(Self::sha(40)?.into_bytes()),
      Some("dirty") => Arc::new(Self::dirty()?.into_bytes()),
      Some("branches") => Arc::new(Self::branches()?.into_bytes()),
      Some("remotes") => Arc::new(Self::remotes()?.into_bytes()),
      Some("remotes-list") => Arc::new(Self::remotes_list()?.into_bytes()),
      Some("remotes-autocomplete") => Arc::new(Self::remotes_autocomplete()?.into_bytes()),
      Some("remote-url") => {
        if payload.len() != 1 {
          return Err(IoError::new(ErrorKind::InvalidInput, "Git remote-url accepts exactly one remote").into());
        }

        Arc::new(Self::remote_url(payload[0])?.into_bytes())
      }
      Some("worktrees") => {
        if payload.len() > 1 {
          return Err(IoError::new(ErrorKind::InvalidInput, "Git worktrees accepts at most one folder").into());
        }

        Arc::new(Self::worktrees(payload.first().copied())?.into_bytes())
      }
      _ => return Err(IoError::new(ErrorKind::InvalidInput, "Unknown command").into()),
    })
  }

  fn is_repository() -> Result<String, Box<dyn Error>> {
    Repository::discover(".")?;
    Ok(String::new())
  }

  fn current_branch_name(full: bool) -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let head = repository.head()?;

    if full {
      return Ok(head.name().unwrap_or("HEAD").to_string());
    }

    Ok(Self::branch_name(&repository).unwrap_or_else(|| "HEAD".to_string()))
  }

  fn sha(length: usize) -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let hash = repository
      .head()?
      .target()
      .map(|hash| hash.to_string())
      .unwrap_or_default();
    Ok(hash.chars().take(length).collect())
  }

  fn dirty() -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let mut options = git2::StatusOptions::new();
    options.include_untracked(true).recurse_untracked_dirs(true);

    if repository.statuses(Some(&mut options))?.is_empty() {
      Ok(String::new())
    } else {
      Ok("true".to_string())
    }
  }

  fn branches() -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let mut branches = repository
      .branches(Some(BranchType::Local))?
      .filter_map(Result::ok)
      .filter_map(|(branch, _)| branch.name().ok().flatten().map(ToString::to_string))
      .collect::<Vec<_>>();

    branches.sort();

    let mut response = String::new();
    for branch in branches {
      response.push_str(&branch);
      response.push_str("\tLocal Branch\n");
    }

    Ok(response)
  }

  fn remotes() -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let mut remotes = BTreeMap::<String, BTreeMap<String, String>>::new();

    for name in repository.remotes()?.iter().flatten() {
      let remote = repository.find_remote(name)?;
      let fetch = remote.url().map(ToString::to_string);
      let push = remote.pushurl().map(ToString::to_string).or_else(|| fetch.clone());

      if let Some(fetch) = fetch {
        remotes
          .entry(name.to_string())
          .or_default()
          .insert("fetch".to_string(), fetch);
      }

      if let Some(push) = push {
        remotes
          .entry(name.to_string())
          .or_default()
          .insert("push".to_string(), push);
      }
    }

    let mut response = Map::new();
    for (name, remote) in remotes {
      match (remote.get("fetch"), remote.get("push")) {
        (Some(fetch), Some(push)) if fetch == push => {
          response.insert(name, Value::String(fetch.clone()));
        }
        _ => {
          response.insert(name, serde_json::to_value(remote)?);
        }
      }
    }

    Ok(serde_json::to_string_pretty(&Value::Object(response))?)
  }

  fn remotes_list() -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let mut response = String::new();

    for name in repository.remotes()?.iter().flatten() {
      response.push_str(name);
      response.push_str("\tRemote\n");
    }

    Ok(response)
  }

  fn remotes_autocomplete() -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let mut response = String::new();

    for name in repository.remotes()?.iter().flatten() {
      let remote = repository.find_remote(name)?;
      if let Some(url) = remote.url() {
        response.push_str(name);
        response.push_str("\tGIT Remote: ");
        response.push_str(url);
        response.push('\n');
      }
    }

    Ok(response)
  }

  fn remote_url(name: &str) -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(".")?;
    let remote = repository.find_remote(name)?;
    Ok(remote.url().unwrap_or_default().to_string())
  }

  fn worktrees(folder: Option<&str>) -> Result<String, Box<dyn Error>> {
    let repository = Repository::discover(folder.unwrap_or("."))?;
    let mut rows = Vec::new();

    if let Some(workdir) = repository.workdir() {
      rows.push((
        Self::worktree_name(workdir),
        workdir.to_path_buf(),
        Self::branch_name(&repository).unwrap_or_default(),
      ));
    }

    for name in repository.worktrees()?.iter().flatten() {
      let worktree = repository.find_worktree(name)?;
      let path = worktree.path().to_path_buf();
      let branch = Repository::open(&path)
        .ok()
        .and_then(|repository| Self::branch_name(&repository))
        .unwrap_or_default();

      rows.push((name.to_string(), path, branch));
    }

    rows.sort_by(|left, right| left.1.cmp(&right.1));
    rows.dedup_by(|left, right| left.1 == right.1);

    let mut response = String::new();
    for (name, path, branch) in rows {
      response.push_str(&name);
      response.push('\t');
      response.push_str(&Self::collapse_home(&path.to_string_lossy())?);
      response.push('\t');
      response.push_str(&branch);
      response.push('\n');
    }

    Ok(response)
  }

  fn branch_name(repository: &Repository) -> Option<String> {
    let head = repository.head().ok()?;
    if head.is_branch() {
      head.shorthand().map(ToString::to_string)
    } else {
      repository
        .branches(Some(BranchType::Local))
        .ok()?
        .filter_map(Result::ok)
        .filter_map(|(branch, _)| {
          branch
            .get()
            .target()
            .filter(|target| Some(*target) == head.target())
            .and_then(|_| branch.name().ok().flatten().map(ToString::to_string))
        })
        .next()
    }
  }

  fn worktree_name(path: &Path) -> String {
    path
      .file_name()
      .map(|name| name.to_string_lossy().into_owned())
      .filter(|name| !name.is_empty())
      .unwrap_or_else(|| path.display().to_string())
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
}
