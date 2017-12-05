#!/usr/bin/env node

import {writeFileSync, readFileSync} from 'fs';
import {resolve} from 'path';

import {buildBookmarksManager} from '../src/helpers/modules/bookmarks';
import {buildGitManager} from '../src/helpers/modules/git/cli';
import { Argv } from 'yargs';

// Define interfaces
interface Argument{
  name: string;
  description: string;
  required: boolean;
  completions: string;
}

interface Option{
  short: string;
  long: string;
  description: string;
  wantsArg: boolean;
  completions: string;
}

interface Command{
  names: Array<string>;
  arguments?: Array<Argument>;
  description: string;
  options?: Array<Option>;
}

// Compatibility wrapper for yargs to get all defined options
class YArgsParser{
  manager: string = '';
  commands: Array<Command> = [];
  options: Array<Option> = [];

  constructor(manager: string){
    this.manager = manager;
  }

  command(
    {command: name, aliases, describe, builder}: {command: string, aliases: Array<string>, describe: string, builder(local: YArgsParser): YArgsParser}
  ): YArgsParser{
    const syntax: Array<string> = name.split(/\s/);

    const command: Command = {
      names: [syntax[0], ...(aliases || [])],
      description: describe, options: [],
      arguments: syntax.slice(1).map((arg: string) => { // Parse <arg> or [arg] syntax
        const mo: RegExpMatchArray = arg.match(/^([<[])(.+).$/);
        let completions: string = null;
        let argDescription: string = `MISSING: ${mo[2]}`;

        if(this.manager === 'git'){
          switch(mo[2]){
            case 'branch':
              argDescription = 'GIT Branch';
              break;
            case 'base':
              argDescription = 'Base GIT branch';
              break;
            case 'message':
              argDescription = 'Commit message';
              break;
            case 'task':
              argDescription = 'Task ID';
              break;
            case 'source':
              argDescription = 'Source GIT branch';
              break;
            case 'task':
              argDescription = 'Destination GIT branch';
              break;
            case 'spec':
              argDescription = 'Version number';
              break;
          }
        }else{
          switch(mo[2]){
            case 'name':
              argDescription = 'Bookmark name';
              completions = 'fishamnium_bookmarks l -a';
              break;
          }
        }

        return {name: mo[2], description: argDescription, completions, required: mo[1] === '<'};
      })
    };

    if(builder){ // Local options
      const local: YArgsParser = new YArgsParser(this.manager);
      builder(local);
      command.options = local.options;
    }

    // Add the new command
    this.commands.push(command);

    return this;
  }

  option(short: string, {alias: long, describe: description, demandOption: wantsArg}: {alias: string, describe: string, demandOption: boolean}): YArgsParser{
    let completions = '';

    if(this.manager === 'git' && long === 'remote')
      completions = ' -a "(fishamnium_git lr -a)"';

    this.options.push({short, long, description, wantsArg, completions});

    return this;
  }
}

const banner: string = readFileSync(resolve(process.cwd(), './scripts/templates/autocompletions.fish'), 'utf-8');

const formatCompletion = function(completion: string): string{
  return completion.replace(/[\t\n]+/g, '').replace(/\s+/g, ' ').trim() + '\n';
};

const printOption = function(o: Option, executable: string, condition: string = ''): string{
  return formatCompletion(`
    complete ${o.wantsArg ? '-x' : ''} -c ${executable} -n "${condition}"
    -s ${o.short} -l ${o.long} ${o.completions} -d "${o.description}"
  `);
};

const printCommand = function(command: Command, executable: string): string{
  let output: string = formatCompletion(`
    complete ${command.arguments.length ? '-x' : '-f'} -c ${executable} -n "__fishamnium_completion_is_global"
    -a "${command.names.join(' ')}" -d "${command.description}"
  `);

  // Local arguments
  if(command.arguments.length){
    for(const argument of command.arguments.filter((a: Argument) => a.completions)){
      output += formatCompletion(`
        complete -f -c ${executable} -n "__fishamnium_completion_is_command ${command.names.join(' ')}"
        -a "(${argument.completions})" -d "${argument.description}"
      `);
    }
  }

  // Local options
  for(const opt of command.options)
    output += printOption(opt, executable, `__fishamnium_completion_is_command ${command.names.join(' ')}`);

  return output;
};

const autocompleteModule = function(manager: (y: Argv) => Argv, module: 'bookmarks' | 'git'){
  const executable: string = `fishamnium_${module}`;
  const wrapper: YArgsParser = new YArgsParser(module);
  manager(wrapper as any);

  let output: string = `${banner}\n\n`;

  // Global options
  for(const opt of wrapper.options)
    output += printOption(opt, executable);

  // Commands
  for(const command of wrapper.commands)
    output += printCommand(command, executable);

  console.log(`---- ${module} ----\n${output}\n`);
  writeFileSync(`./src/completions/71_fishamnium_${module}.fish`, output, {encoding: 'utf8'});
};

autocompleteModule(buildBookmarksManager, 'bookmarks');
autocompleteModule(buildGitManager, 'git');
