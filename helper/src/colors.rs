use crate::config::Config;
use crate::env::Environment;
use std::error::Error;
use std::path::Path;

pub struct Palette {
  // Fixed colors
  pub white: &'static str,
  pub black: &'static str,
  pub lightgreen: &'static str,
  pub yellow: &'static str,
  pub magenta: &'static str,
  pub blue: &'static str,
  pub gray: &'static str,
  pub lightgray: &'static str,
  // Variable colors
  pub red: &'static str,
  pub green: &'static str,
  pub cyan: &'static str,
  pub foreground: &'static str,
  pub primary: &'static str,
  pub secondary: &'static str,
}

pub struct Colors {
  pub profile: String,
  pub palette: Palette,
}

impl Colors {
  pub fn new(profile: Option<&str>) -> Result<Self, Box<dyn Error>> {
    let environment = Environment::new()?;
    let config_path = Path::new(environment.config());
    let mut config = Config::load(config_path)?;

    let profile = match profile {
      Some(profile) => {
        config.profile = profile.to_string();
        config.save(config_path)?;
        profile.to_string()
      }
      None => config.profile,
    }
    .to_lowercase();

    let white = "FFFFFF";
    let black = "000000";
    let lightgreen = "00CC00";
    let yellow = "FFDF00";
    let magenta = "C800E2";
    let blue = "005be4";
    let gray = "808080";
    let lightgray = "C0C0C0";

    let palette = if profile == "light" {
      let cyan = "0088E2";

      Palette {
        white,
        black,
        lightgreen,
        yellow,
        magenta,
        blue,
        gray,
        lightgray,
        red: "CC0000",
        green: "00CC00",
        cyan,
        foreground: black,
        primary: cyan,
        secondary: magenta,
      }
    } else {
      let cyan = "5EBBF9";

      Palette {
        white,
        black,
        lightgreen,
        yellow,
        magenta,
        blue,
        gray,
        lightgray,
        red: "EE0000",
        green: "00EE00",
        cyan,
        foreground: white,
        primary: yellow,
        secondary: cyan,
      }
    };

    Ok(Self { profile, palette })
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

  fn push_variables(&self, response: &mut String, mut push: impl FnMut(&mut String, &str, &str)) {
    push(response, "FISHAMNIUM_COLOR_PROFILE", &self.profile);
    push(response, "FISHAMNIUM_COLOR_RESET", "\x1b[0m");
    push(response, "FISHAMNIUM_COLOR_BOLD", "\x1b[1m");
    push(response, "FISHAMNIUM_COLOR_NORMAL", "\x1b[22m");
    push(response, "FISHAMNIUM_COLOR_ERROR", &self.foreground(self.palette.red));
    push(
      response,
      "FISHAMNIUM_COLOR_SUCCESS",
      &self.foreground(self.palette.green),
    );
    push(
      response,
      "FISHAMNIUM_COLOR_PRIMARY",
      &self.foreground(self.palette.primary),
    );
    push(
      response,
      "FISHAMNIUM_COLOR_SECONDARY",
      &self.foreground(self.palette.secondary),
    );
    push(
      response,
      "FISHAMNIUM_INTERACTIVE_COLORS",
      "prompt:3:bold,bg+:-1,fg+:2:bold,pointer:2:bold,hl:-1:underline,hl+:2:bold:underline",
    );

    for (name, color) in [
      ("WHITE", self.palette.white),
      ("BLACK", self.palette.black),
      ("RED", self.palette.red),
      ("GREEN", self.palette.green),
      ("LIGHTGREEN", self.palette.lightgreen),
      ("YELLOW", self.palette.yellow),
      ("MAGENTA", self.palette.magenta),
      ("BLUE", self.palette.blue),
      ("CYAN", self.palette.cyan),
      ("GRAY", self.palette.gray),
      ("LIGHTGRAY", self.palette.lightgray),
      ("FOREGROUND", self.palette.foreground),
      ("PRIMARY", self.palette.primary),
      ("SECONDARY", self.palette.secondary),
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
