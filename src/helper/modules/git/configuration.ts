import {existsSync} from 'fs';
import {dirname, resolve as resolvePath} from 'path';
import chalk from 'chalk';

import {warn} from '../../utils/console';

interface Configuration{
  defaultBranch?: string;
  defaultRemote?: string;
  defaultPrefix?: string;
  openPath?: string;
  prependTask?: boolean;
  quiet?: boolean;
  debug?: boolean;
}

export let configuration: Configuration = null;

const fallbackConfiguration: Configuration = {
  defaultBranch: 'development',
  defaultRemote: 'origin',
  defaultPrefix: 'release-',
  openPath: '/usr/bin/open',
  prependTask: false,
  quiet: false,
  debug: false
};

export function environmentConfiguration(): Configuration{
  const envConfiguration: Configuration = {};

  if(Reflect.has(process.env, 'GIT_DEFAULT_BRANCH'))
    envConfiguration.defaultBranch = process.env.GIT_DEFAULT_BRANCH;
  if(Reflect.has(process.env, 'GIT_DEFAULT_REMOTE'))
    envConfiguration.defaultRemote = process.env.GIT_DEFAULT_REMOTE;
  if(Reflect.has(process.env, 'GIT_DEFAULT_PREFIX'))
    envConfiguration.defaultPrefix = process.env.GIT_DEFAULT_PREFIX;
  if(Reflect.has(process.env, 'GIT_OPEN_PATH'))
    envConfiguration.openPath = process.env.GIT_OPEN_PATH;
  if(Reflect.has(process.env, 'GIT_TASK_PREPEND'))
    envConfiguration.prependTask = process.env.GIT_TASK_PREPEND === 'true';
  if(Reflect.has(process.env, 'QUIET'))
    envConfiguration.quiet = process.env.QUIET === 'true';
  if(Reflect.has(process.env, 'DEBUG'))
    envConfiguration.debug = process.env.DEBUG === 'true';

  return envConfiguration;
}

export function loadConfiguration(): Configuration{
  // First of all, try to load the file starting from the current folder and traversing up to root - Then trying with the home folder
  let configPath: string = null;
  const folders = new Set<string>();

  for(let currentFolder of [process.cwd(), process.env['HOME']]){
    while(currentFolder !== ''){
      if(folders.has(currentFolder))
        break;

      folders.add(currentFolder);
      currentFolder = currentFolder === '/' ? '' : dirname(currentFolder);
    }
  }

  for(const currentFolder of Array.from(folders)){
    const temporaryPath: string = resolvePath(currentFolder, '.fishamnium_git.json');

    if(existsSync(temporaryPath)){
      configPath = temporaryPath;
      break;
    }
  }

  // Now load the file
  if(configPath){
    try{
      configuration = require(configPath);
    }catch(e){
      warn(chalk`The configuration file {bold ${configPath}} is not a valid JSON. Ignoring it.`);
    }
  }

  // Now merge configuration
  configuration = {...fallbackConfiguration, ...configuration, ...environmentConfiguration()};

  return configuration;
}
