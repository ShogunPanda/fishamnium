use crate::colors::Colors;
use crossterm::cursor;
use crossterm::event::{self, Event, KeyCode, KeyModifiers};
use crossterm::execute;
use crossterm::terminal::{self, Clear, ClearType, disable_raw_mode, enable_raw_mode};
use std::collections::BTreeSet;
use std::error::Error;
use std::fs::OpenOptions;
use std::io::{Error as IoError, ErrorKind, IsTerminal, Read, Write, stdin};

pub struct Select;

const COLUMN_SEPARATOR: &str = "     ";

struct Choice {
  fields: Vec<String>,
  raw: String,
}

struct Options {
  prompt: String,
  multiselect: bool,
  raw: bool,
}

impl Select {
  pub fn from_stdin(payload: &[String]) -> Result<String, Box<dyn Error>> {
    let options = Self::parse_options(payload)?;
    let choices = Self::read_choices()?;

    let Some(indices) = Self::select(&choices, &options)? else {
      return Ok(String::new());
    };

    if indices.is_empty() {
      return Ok(String::new());
    }

    Ok(
      indices
        .iter()
        .map(|index| {
          if options.raw {
            choices[*index].raw.as_str()
          } else {
            choices[*index].fields[0].as_str()
          }
        })
        .collect::<Vec<_>>()
        .join("\n")
        + "\n",
    )
  }

  fn select(choices: &[Choice], options: &Options) -> Result<Option<Vec<usize>>, Box<dyn Error>> {
    if choices.is_empty() {
      return Ok(None);
    }

    let colors = Colors::new(None)?;
    let color_reset = "\x1b[0m";
    let color_bold = "\x1b[1m";
    let highlight_background = colors.background(&colors.palette.cyan);
    let highlight_foreground = colors.foreground(&colors.palette.white);
    let prompt_foreground = colors.foreground(&colors.palette.primary);
    let path_foreground = colors.foreground(&colors.palette.gray);
    let mut output = match OpenOptions::new().read(true).write(true).open("/dev/tty") {
      Ok(output) => output,
      Err(_) => return Ok(None),
    };
    if !output.is_terminal() {
      return Ok(None);
    }

    enable_raw_mode()?;

    let result = (|| -> Result<Option<Vec<usize>>, Box<dyn Error>> {
      let height = choices.len().min(10) + 1;
      let mut current = 0;
      let terminal_width = terminal::size()
        .map(|(width, _)| width.saturating_sub(1).max(1) as usize)
        .unwrap_or(79);
      let widths = Self::column_widths(choices, options.multiselect, terminal_width);
      let mut query = String::new();
      let mut selected = BTreeSet::new();
      let mut rendered = false;

      let selection = loop {
        let filtered = Self::filter_choices(choices, &query);
        current = current.min(filtered.len().saturating_sub(1));

        Self::render(
          &mut output,
          choices,
          &filtered,
          current,
          &selected,
          options,
          &query,
          &widths,
          height,
          rendered,
          terminal_width,
          &prompt_foreground,
          &path_foreground,
          &highlight_foreground,
          &highlight_background,
          color_bold,
          color_reset,
        )?;
        rendered = true;

        if let Event::Key(key) = event::read()? {
          match key.code {
            KeyCode::Char('c') if key.modifiers.contains(KeyModifiers::CONTROL) => break None,
            KeyCode::Esc => break None,
            KeyCode::Enter if options.multiselect => break Some(selected.into_iter().collect()),
            KeyCode::Enter => break (!filtered.is_empty()).then_some(vec![filtered[current]]),
            KeyCode::Tab if options.multiselect => {
              if !filtered.is_empty() {
                let index = filtered[current];
                if selected.contains(&index) {
                  selected.remove(&index);
                } else {
                  selected.insert(index);
                }

                current = (current + 1).min(filtered.len() - 1);
              }
            }
            KeyCode::Up | KeyCode::Char('k') => {
              if !filtered.is_empty() {
                current = current.saturating_sub(1);
              }
            }
            KeyCode::Down | KeyCode::Char('j') => {
              if !filtered.is_empty() {
                current = (current + 1).min(filtered.len() - 1);
              }
            }
            KeyCode::Backspace => {
              query.pop();
            }
            KeyCode::Char(character) => {
              query.push(character);
            }
            _ => {}
          }
        }
      };

      if rendered {
        Self::clear_rendered(&mut output, height)?;
      }

      Ok(selection)
    })();

    disable_raw_mode()?;

    result
  }

  fn filter_choices(choices: &[Choice], query: &str) -> Vec<usize> {
    choices
      .iter()
      .enumerate()
      .filter_map(|(index, choice)| Self::match_positions(choice, query).is_some().then_some(index))
      .collect()
  }

  fn match_positions(choice: &Choice, query: &str) -> Option<Vec<BTreeSet<usize>>> {
    if query.is_empty() {
      return Some(vec![BTreeSet::new(); choice.fields.len()]);
    }

    let matches = choice
      .fields
      .iter()
      .map(|field| Self::substring_positions(field, query))
      .collect::<Vec<_>>();

    matches.iter().any(|matches| !matches.is_empty()).then_some(matches)
  }

  fn render(
    output: &mut impl Write,
    choices: &[Choice],
    filtered: &[usize],
    current: usize,
    selected: &BTreeSet<usize>,
    options: &Options,
    query: &str,
    widths: &[usize],
    height: usize,
    rendered: bool,
    terminal_width: usize,
    prompt_foreground: &str,
    path_foreground: &str,
    highlight_foreground: &str,
    highlight_background: &str,
    color_bold: &str,
    color_reset: &str,
  ) -> Result<(), Box<dyn Error>> {
    if rendered {
      execute!(output, cursor::MoveUp(height as u16))?;
    }

    write!(output, "\r")?;
    execute!(output, Clear(ClearType::CurrentLine))?;
    let question = format!("--> {}", options.prompt);
    let question_width = question.chars().count().min(terminal_width);
    write!(
      output,
      "\r{prompt_foreground}{color_bold}{}{color_reset}",
      question.chars().take(question_width).collect::<String>()
    )?;
    if !query.is_empty() && question_width < terminal_width {
      let query = format!(" {query}");
      write!(
        output,
        "{}",
        query.chars().take(terminal_width - question_width).collect::<String>()
      )?;
    }
    write!(output, "\r\n")?;

    for row in 0..height - 1 {
      write!(output, "\r")?;
      execute!(output, Clear(ClearType::CurrentLine))?;

      if let Some(index) = filtered.get(row) {
        let choice = &choices[*index];
        let is_cursor = row == current;
        let is_selected = options.multiselect && selected.contains(index);
        let matches = Self::match_positions(choice, query).unwrap_or_default();
        let marker = if is_selected {
          "* "
        } else if options.multiselect {
          "  "
        } else {
          ""
        };

        if is_cursor {
          write!(output, "{highlight_background}{highlight_foreground}{color_bold}> ")?;
        } else {
          write!(output, "  ")?;
          if is_selected {
            write!(output, "{color_bold}")?;
          }
        }

        for (field_index, field) in choice.fields.iter().enumerate() {
          if field_index > 0 {
            write!(output, "{COLUMN_SEPARATOR}")?;
          }

          let text = if field_index == 0 {
            format!("{marker}{field}")
          } else {
            field.to_string()
          };
          let field_matches = if field_index == 0 {
            matches
              .get(field_index)
              .unwrap_or(&BTreeSet::new())
              .iter()
              .map(|index| index + marker.len())
              .collect::<BTreeSet<_>>()
          } else {
            matches.get(field_index).cloned().unwrap_or_default()
          };
          let field_color = if !is_cursor && field_index > 0 {
            path_foreground
          } else {
            ""
          };

          write!(
            output,
            "{}",
            Self::styled_text(
              &text,
              &field_matches,
              widths[field_index],
              field_color,
              color_bold,
              color_reset
            )
          )?;

          if is_cursor {
            write!(output, "{highlight_background}{highlight_foreground}{color_bold}")?;
          } else if is_selected {
            write!(output, "{color_bold}")?;
          }
        }

        write!(output, "{color_reset}")?;
      }

      write!(output, "\r\n")?;
    }

    output.flush()?;
    Ok(())
  }

  fn clear_rendered(output: &mut impl Write, height: usize) -> Result<(), Box<dyn Error>> {
    execute!(output, cursor::MoveUp(height as u16))?;

    for _ in 0..height {
      write!(output, "\r")?;
      execute!(output, Clear(ClearType::CurrentLine))?;
      write!(output, "\r\n")?;
    }

    execute!(output, cursor::MoveUp(height as u16))?;
    output.flush()?;
    Ok(())
  }

  fn column_widths(choices: &[Choice], multiselect: bool, terminal_width: usize) -> Vec<usize> {
    let columns = choices.iter().map(|choice| choice.fields.len()).max().unwrap_or(1);
    let mut widths = vec![0; columns];

    for choice in choices {
      for (index, field) in choice.fields.iter().enumerate() {
        widths[index] = widths[index].max(field.chars().count());
      }
    }

    for (index, width) in widths.iter_mut().enumerate() {
      *width += if index == 0 && multiselect { 4 } else { 2 };
    }

    let separators = columns.saturating_sub(1) * COLUMN_SEPARATOR.len();
    while 2 + separators + widths.iter().sum::<usize>() > terminal_width {
      let Some((index, width)) = widths.iter().enumerate().max_by_key(|(_, width)| **width) else {
        break;
      };

      if *width <= 1 {
        break;
      }

      widths[index] -= 1;
    }

    widths
  }

  fn substring_positions(text: &str, query: &str) -> BTreeSet<usize> {
    let mut matches = BTreeSet::new();
    let text_lowercase = text.to_lowercase();
    let query_lowercase = query.to_lowercase();
    let mut offset = 0;

    while let Some(index) = text_lowercase[offset..].find(&query_lowercase) {
      let start = offset + index;
      let end = start + query_lowercase.len();
      let start_character = text_lowercase[..start].chars().count();
      let character_count = text_lowercase[start..end].chars().count();

      for index in start_character..start_character + character_count {
        matches.insert(index);
      }

      offset = end;
    }

    matches
  }

  fn styled_text(
    text: &str,
    matches: &BTreeSet<usize>,
    width: usize,
    color: &str,
    color_bold: &str,
    color_reset: &str,
  ) -> String {
    let mut response = String::new();

    if !color.is_empty() {
      response.push_str(color);
    }

    for (index, character) in text.chars().enumerate() {
      if index >= width {
        break;
      }

      if matches.contains(&index) {
        response.push_str(color_bold);
      }

      response.push(character);

      if matches.contains(&index) {
        response.push_str(color_reset);
        if !color.is_empty() {
          response.push_str(color);
        }
      }
    }

    for _ in text.chars().count().min(width)..width {
      response.push(' ');
    }

    response
  }

  fn parse_options(payload: &[String]) -> Result<Options, Box<dyn Error>> {
    let mut prompt = "Select?".to_string();
    let mut multiselect = false;
    let mut raw = false;
    let mut index = 0;

    while index < payload.len() {
      let argument = &payload[index];

      if argument == "--multi" {
        multiselect = true;
      } else if argument == "--raw" {
        raw = true;
      } else if argument == "--prompt" {
        index += 1;
        prompt = Self::normalize_prompt(
          payload
            .get(index)
            .ok_or_else(|| IoError::new(ErrorKind::InvalidInput, "Missing value for --prompt"))?
            .as_str(),
        );
      } else if let Some(value) = argument.strip_prefix("--prompt=") {
        prompt = Self::normalize_prompt(value);
      } else {
        return Err(IoError::new(ErrorKind::InvalidInput, format!("Unknown select option: {argument}")).into());
      }

      index += 1;
    }

    Ok(Options {
      prompt,
      multiselect,
      raw,
    })
  }

  fn normalize_prompt(prompt: &str) -> String {
    let prompt = prompt.trim_end();

    if prompt.ends_with('?') {
      prompt.to_string()
    } else {
      format!("{prompt}?")
    }
  }

  fn read_choices() -> Result<Vec<Choice>, Box<dyn Error>> {
    let mut stdin = stdin();
    if stdin.is_terminal() {
      return Ok(Vec::new());
    }

    let mut input = String::new();
    stdin.read_to_string(&mut input)?;

    Ok(
      input
        .split(['\n', '\0'])
        .filter_map(|line| {
          let fields = line
            .split('\t')
            .map(|field| field.trim().to_string())
            .collect::<Vec<_>>();
          let id = fields.first()?;

          if id.is_empty() {
            None
          } else {
            Some(Choice {
              fields,
              raw: line.to_string(),
            })
          }
        })
        .collect(),
    )
  }
}
