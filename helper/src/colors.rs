use crate::config::Config;
use crate::defaults::*;
use crate::env::Environment;
use std::error::Error;
use std::path::Path;

#[derive(Clone, Copy)]
struct ThemeDefaults {
  red: &'static str,
  green: &'static str,
  cyan: &'static str,
  foreground: &'static str,
  primary: &'static str,
  secondary: &'static str,
}

const LIGHT_THEME_DEFAULTS: ThemeDefaults = ThemeDefaults {
  red: COLORS_LIGHT_RED,
  green: COLORS_LIGHT_GREEN,
  cyan: COLORS_LIGHT_CYAN,
  foreground: COLORS_BLACK,
  primary: COLORS_LIGHT_CYAN,
  secondary: COLORS_MAGENTA,
};

const DARK_THEME_DEFAULTS: ThemeDefaults = ThemeDefaults {
  red: COLORS_DARK_RED,
  green: COLORS_DARK_GREEN,
  cyan: COLORS_DARK_CYAN,
  foreground: COLORS_WHITE,
  primary: COLORS_YELLOW,
  secondary: COLORS_DARK_CYAN,
};

pub struct Palette {
  // Fixed colors
  pub white: String,
  pub black: String,
  pub lightgreen: String,
  pub yellow: String,
  pub magenta: String,
  pub blue: String,
  pub gray: String,
  pub lightgray: String,
  pub orange: String,
  // Variable colors
  pub red: String,
  pub green: String,
  pub cyan: String,
  pub foreground: String,
  pub primary: String,
  pub secondary: String,
}

pub struct Colors {
  pub theme: String,
  pub palette: Palette,
}

impl Colors {
  pub fn new(theme: Option<&str>) -> Result<Self, Box<dyn Error>> {
    Self::load(theme, true)
  }

  pub fn for_theme(theme: Option<&str>) -> Result<Self, Box<dyn Error>> {
    Self::load(theme, false)
  }

  fn load(theme: Option<&str>, save: bool) -> Result<Self, Box<dyn Error>> {
    let environment = Environment::new()?;
    let config_path = Path::new(&environment.config);
    let default_path = Path::new(&environment.root).join("default.yml");
    let mut config = Config::load(config_path)?;
    let default = Config::load(&default_path)?;

    let theme = match theme {
      Some(theme) => {
        let theme = theme.to_lowercase();

        if save {
          config.theme = theme.clone();
          Config::save_theme(config_path, &theme)?;
        }

        theme
      }
      None => config.theme.to_lowercase(),
    };

    let palette = if theme == "light" {
      Self::palette(&config, &default, "light", LIGHT_THEME_DEFAULTS)?
    } else {
      Self::palette(&config, &default, "dark", DARK_THEME_DEFAULTS)?
    };

    Ok(Self { theme, palette })
  }

  fn palette(
    config: &Config,
    default: &Config,
    theme: &str,
    fallback: ThemeDefaults,
  ) -> Result<Palette, Box<dyn Error>> {
    Ok(Palette {
      white: Self::color(config, default, theme, "white", COLORS_WHITE)?,
      black: Self::color(config, default, theme, "black", COLORS_BLACK)?,
      lightgreen: Self::color(config, default, theme, "lightgreen", COLORS_LIGHTGREEN)?,
      yellow: Self::color(config, default, theme, "yellow", COLORS_YELLOW)?,
      magenta: Self::color(config, default, theme, "magenta", COLORS_MAGENTA)?,
      blue: Self::color(config, default, theme, "blue", COLORS_BLUE)?,
      gray: Self::color(config, default, theme, "gray", COLORS_GRAY)?,
      lightgray: Self::color(config, default, theme, "lightgray", COLORS_LIGHTGRAY)?,
      orange: Self::color(config, default, theme, "orange", COLORS_ORANGE)?,
      red: Self::color(config, default, theme, "red", fallback.red)?,
      green: Self::color(config, default, theme, "green", fallback.green)?,
      cyan: Self::color(config, default, theme, "cyan", fallback.cyan)?,
      foreground: Self::color(config, default, theme, "foreground", fallback.foreground)?,
      primary: Self::color(config, default, theme, "primary", fallback.primary)?,
      secondary: Self::color(config, default, theme, "secondary", fallback.secondary)?,
    })
  }

  fn color(
    config: &Config,
    default: &Config,
    theme: &str,
    name: &str,
    fallback: &str,
  ) -> Result<String, Box<dyn Error>> {
    let selector = format!("colors.{theme}.{name}");
    let default_value = default.get(Some(&selector), &[fallback])?;
    config.get(Some(&selector), &[&default_value])
  }

  pub fn to_response(&self) -> Vec<u8> {
    let mut response = String::new();

    self.push_variables(&mut response, |response, name, value| {
      self.push_env(response, name, value)
    });
    response.into_bytes()
  }

  pub fn to_fish_response(&self) -> Vec<u8> {
    let mut response = String::new();

    self.push_variables(&mut response, |response, name, value| {
      Environment::push_fish_variable(response, name, &[value])
    });
    response.into_bytes()
  }

  pub fn foreground(&self, color: &str) -> String {
    let (red, green, blue) = self.rgb(color);
    format!("\x1b[38;2;{red};{green};{blue}m")
  }

  pub fn background(&self, color: &str) -> String {
    let (red, green, blue) = self.rgb(color);
    format!("\x1b[48;2;{red};{green};{blue}m")
  }

  pub fn rgb(&self, color: &str) -> (u8, u8, u8) {
    let red = u8::from_str_radix(&color[0..2], 16).unwrap_or(0);
    let green = u8::from_str_radix(&color[2..4], 16).unwrap_or(0);
    let blue = u8::from_str_radix(&color[4..6], 16).unwrap_or(0);

    (red, green, blue)
  }

  pub fn fzf_theme(&self) -> String {
    format!(
      "{},prompt:#{}:bold,bg+:-1,fg+:#{}:bold,pointer:#{}:bold,marker:#{}:bold,hl:#{}:underline,hl+:#{}:bold:underline",
      self.theme,
      self.palette.primary,
      self.palette.foreground,
      self.palette.primary,
      self.palette.primary,
      self.palette.foreground,
      self.palette.primary,
    )
  }

  fn push_variables(&self, response: &mut String, mut push: impl FnMut(&mut String, &str, &str)) {
    push(response, "FISHAMNIUM_COLOR_THEME", &self.theme);
    push(response, "FISHAMNIUM_COLOR_RESET", "\x1b[0m");
    push(response, "FISHAMNIUM_COLOR_BOLD", "\x1b[1m");
    push(response, "FISHAMNIUM_COLOR_NORMAL", "\x1b[22m");
    push(response, "FISHAMNIUM_COLOR_ERROR", &self.foreground(&self.palette.red));
    push(
      response,
      "FISHAMNIUM_COLOR_SUCCESS",
      &self.foreground(&self.palette.green),
    );
    push(
      response,
      "FISHAMNIUM_COLOR_PRIMARY",
      &self.foreground(&self.palette.primary),
    );
    push(
      response,
      "FISHAMNIUM_COLOR_SECONDARY",
      &self.foreground(&self.palette.secondary),
    );
    for (name, color) in [
      ("WHITE", self.palette.white.as_str()),
      ("BLACK", self.palette.black.as_str()),
      ("RED", self.palette.red.as_str()),
      ("GREEN", self.palette.green.as_str()),
      ("LIGHTGREEN", self.palette.lightgreen.as_str()),
      ("YELLOW", self.palette.yellow.as_str()),
      ("MAGENTA", self.palette.magenta.as_str()),
      ("BLUE", self.palette.blue.as_str()),
      ("CYAN", self.palette.cyan.as_str()),
      ("GRAY", self.palette.gray.as_str()),
      ("LIGHTGRAY", self.palette.lightgray.as_str()),
      ("ORANGE", self.palette.orange.as_str()),
      ("FOREGROUND", self.palette.foreground.as_str()),
      ("PRIMARY", self.palette.primary.as_str()),
      ("SECONDARY", self.palette.secondary.as_str()),
    ] {
      push(response, &format!("FISHAMNIUM_COLOR_{name}"), color);
      push(
        response,
        &format!("FISHAMNIUM_COLOR_FG_{name}"),
        &self.foreground(color),
      );
      push(
        response,
        &format!("FISHAMNIUM_COLOR_BG_{name}"),
        &self.background(color),
      );
    }
  }

  fn push_env(&self, response: &mut String, name: &str, value: &str) {
    response.push_str(name);
    response.push('=');
    response.push_str(&Environment::quote_env_value(value));
    response.push('\n');
  }
}
