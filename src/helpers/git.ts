import * as yargs from 'yargs';
import {buildGitManager} from './modules/git/cli';

interface PackageInfo{
  version: string;
}

declare const packageInfo: PackageInfo;

buildGitManager(yargs.version(packageInfo.version)) // tslint:disable-line no-unused-expression
  .command({command: '*', handler: () => yargs.showHelp()})
  .help('help').alias('h', 'help')
  .strict()
  .locale('en')
  .wrap(0)
  .showHelpOnFail(true)
  .argv;
