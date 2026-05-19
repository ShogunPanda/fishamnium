use std::io::{Error, ErrorKind, Result};

const MAX_ARGUMENT_COUNT: usize = i8::MAX as usize;
const MAX_MESSAGE_SIZE: usize = u16::MAX as usize;

#[derive(Debug, PartialEq)]
pub enum Response {
  Ok(Option<Vec<u8>>),
  Error(String),
}

fn ensure_message_size(output: &[u8]) -> Result<()> {
  if output.len() > MAX_MESSAGE_SIZE {
    return Err(Error::new(
      ErrorKind::InvalidInput,
      format!("message length {} exceeds maximum {MAX_MESSAGE_SIZE}", output.len()),
    ));
  }

  Ok(())
}

fn push_argument(output: &mut Vec<u8>, argument: &[u8]) -> Result<()> {
  if argument.len() > MAX_MESSAGE_SIZE {
    return Err(Error::new(
      ErrorKind::InvalidInput,
      format!("argument length {} exceeds maximum {MAX_MESSAGE_SIZE}", argument.len()),
    ));
  }

  output.extend_from_slice(&(argument.len() as u16).to_be_bytes());
  output.extend_from_slice(argument);
  Ok(())
}

fn encode_arguments(arguments: &[&[u8]]) -> Result<Vec<u8>> {
  if arguments.len() > MAX_ARGUMENT_COUNT {
    return Err(Error::new(
      ErrorKind::InvalidInput,
      format!(
        "argument count {} exceeds maximum {MAX_ARGUMENT_COUNT}",
        arguments.len()
      ),
    ));
  }

  let mut output = Vec::new();
  output.push(arguments.len() as u8);

  for argument in arguments {
    push_argument(&mut output, argument)?;
  }

  ensure_message_size(&output)?;
  Ok(output)
}

fn decode_arguments(payload: &[u8]) -> Result<(i8, Vec<Vec<u8>>)> {
  let Some((&count, rest)) = payload.split_first() else {
    return Err(Error::new(
      ErrorKind::UnexpectedEof,
      "message is missing argument count",
    ));
  };

  let count = count as i8;
  let expected = if count == -1 { 1 } else { count.max(0) as usize };
  let mut arguments = Vec::with_capacity(expected);
  let mut cursor = rest;

  for _ in 0..expected {
    if cursor.len() < 2 {
      return Err(Error::new(
        ErrorKind::UnexpectedEof,
        "message is missing argument length",
      ));
    }

    let argument_len = u16::from_be_bytes([cursor[0], cursor[1]]) as usize;
    cursor = &cursor[2..];

    if cursor.len() < argument_len {
      return Err(Error::new(
        ErrorKind::UnexpectedEof,
        "message is missing argument payload",
      ));
    }

    arguments.push(cursor[..argument_len].to_vec());
    cursor = &cursor[argument_len..];
  }

  if !cursor.is_empty() {
    return Err(Error::new(ErrorKind::InvalidInput, "message has trailing bytes"));
  }

  Ok((count, arguments))
}

pub fn encode_request(arguments: &[String]) -> Result<Vec<u8>> {
  let arguments = arguments.iter().map(String::as_bytes).collect::<Vec<_>>();
  encode_arguments(&arguments)
}

pub fn encode_response(argument: Option<&[u8]>) -> Result<Vec<u8>> {
  encode_arguments(&argument.into_iter().collect::<Vec<_>>())
}

pub fn encode_error(argument: &str) -> Result<Vec<u8>> {
  let mut output = Vec::new();
  output.push(-1i8 as u8);
  push_argument(&mut output, argument.as_bytes())?;
  ensure_message_size(&output)?;
  Ok(output)
}

pub fn decode_request(payload: &[u8]) -> Result<Vec<String>> {
  let (count, arguments) = decode_arguments(payload)?;

  if count < 0 {
    return Err(Error::new(
      ErrorKind::InvalidInput,
      "requests cannot use a negative argument count",
    ));
  }

  arguments
    .into_iter()
    .map(|argument| {
      String::from_utf8(argument)
        .map_err(|_| Error::new(ErrorKind::InvalidInput, "message argument is not valid UTF-8"))
    })
    .collect()
}

pub fn decode_response(payload: &[u8]) -> Result<Response> {
  let (count, arguments) = decode_arguments(payload)?;

  match count {
    -1 if arguments.len() == 1 => Ok(Response::Error(
      String::from_utf8(arguments.into_iter().next().unwrap_or_default())
        .map_err(|_| Error::new(ErrorKind::InvalidInput, "message argument is not valid UTF-8"))?,
    )),
    -1 => Err(Error::new(
      ErrorKind::InvalidInput,
      "error responses must contain exactly one argument",
    )),
    0 => Ok(Response::Ok(None)),
    1 => Ok(Response::Ok(Some(arguments.into_iter().next().unwrap_or_default()))),
    count if count < 0 => Err(Error::new(
      ErrorKind::InvalidInput,
      "unsupported negative response count",
    )),
    _ => Err(Error::new(
      ErrorKind::InvalidInput,
      "success responses can contain at most one argument",
    )),
  }
}
