import * as yargs from 'yargs';
import {buildBookmarksManager} from './modules/bookmarks';

interface PackageInfo{
  version: string;
}

declare const packageInfo: PackageInfo;

buildBookmarksManager(yargs.version(packageInfo.version))  // tslint:disable-line no-unused-expression
  .command({command: '*', handler: () => yargs.showHelp()})
  .help('help').alias('h', 'help')
  .strict()
  .locale('en')
  .wrap(0)
  .showHelpOnFail(true)
  .argv;
