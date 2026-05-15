use clap::Parser;

#[derive(Parser)]
#[command(disable_help_flag = true, disable_help_subcommand = true)]
pub struct Arguments {
  #[arg(long, conflicts_with = "client")]
  pub server: bool,

  #[arg(long, value_name = "IP:PORT", conflicts_with = "server")]
  pub client: Option<String>,

  #[arg(allow_hyphen_values = true)]
  pub command: Option<String>,

  #[arg(trailing_var_arg = true, allow_hyphen_values = true)]
  pub payload: Vec<String>,
}
