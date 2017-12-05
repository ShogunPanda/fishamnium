import chalk from 'chalk';

export function success(message: string, print: boolean = true, colored = true, icon = '\u{1F37B}'): string | void{
  const formatted: string = chalk`{${colored ? 'green' : ''} ${icon}\u0020 ${message}}`;

  return print ? console.error(formatted) : formatted;
}

export function warn(message: string, print: boolean = true, colored = true, icon = '\u{26A0}'): string | void{
  const formatted: string = chalk`{${colored ? 'yellow' : ''} ${icon}\u0020 ${message}}`;

  return print ? console.log(formatted) : formatted;
}

export function fail(message: string, print: boolean = true, errorCode: number = 1, icon = '\u{274C}'): string{
  const formatted: string = chalk`{red ${icon}\u0020 ${message}} `;

  if(print)
    console.error(formatted);

  if(errorCode)
    process.exit(errorCode);

  return formatted;
}

export function debug(message: string, print: boolean = true, colored = true, icon = '\u{1F4AC}'): string | void{
  const formatted: string = chalk`{${colored ? 'blue' : ''} ${icon}\u0020 ${message}}`;

  return print ? console.log(formatted) : formatted;
}
