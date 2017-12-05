import * as yargs from 'yargs';
import {buildBookmarksManager} from './modules/bookmarks';
import {buildGitManager} from './modules/git/cli';

interface PackageInfo{
  version: string;
}

declare const packageInfo: PackageInfo;

// Move this to fish code - Require that very first command is either g or b
const verifyAutocompletion = function(): void{
  const args: Array<string> = process.argv.slice(3);
  let commands: Array<string> = [];

  // Parse valid commands
  if(args[0] !== '--')
    commands = args.shift().split('#');

  args.shift(); // Remove --
  args.shift(); // Remove fishamnium

  const currentCommand: string = args[0];

  process.exit((!currentCommand && !commands.length) || commands.includes(currentCommand) ? 0 : 1);
};

yargs // tslint:disable-line no-unused-expression
  .version(packageInfo.version)
  .command({command: 'bookmarks', aliases: ['b'], describe: 'manages bookmarks', builder: buildBookmarksManager, handler: () => yargs.showHelp()})
  .command({command: 'git', aliases: ['g'], describe: 'manages git workflow', builder: buildGitManager, handler: () => yargs.showHelp()})
  .command({command: 'autocomplete', aliases: ['a'], describe: 'verify autocompletion', handler: verifyAutocompletion})
  .command({command: '*', handler: () => yargs.showHelp()})
  .help('help').alias('h', 'help')
  .strict()
  .locale('en')
  .wrap(0)
  .showHelpOnFail(true)
  .argv;
