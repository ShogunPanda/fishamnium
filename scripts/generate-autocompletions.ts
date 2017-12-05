#!/usr/bin/env node

import {writeFileSync} from 'fs';
import {format} from 'util';

import {buildBookmarksManager} from '../src/helper/modules/bookmarks';
import {buildGitManager} from '../src/helper/modules/git/cli';
import { Argv } from 'yargs';

// Define interfaces
interface Argument{
  name: string;
  description: string;
  required: boolean;
}

interface Option{
  short: string;
  long: string;
  description: string;
  wantsArg: boolean;
}

interface Command{
  names: Array<string>;
  arguments?: Array<Argument>;
  description: string;
  options?: Array<Option>;
}

// Compatibility wrapper for yargs to get all defined options
class YArgsParser{
  commands: Array<Command> = [];
  options: Array<Option> = [];

  command(
    {command: name, aliases, describe, builder}: {command: string, aliases: Array<string>, describe: string, builder(local: YArgsParser): YArgsParser}
  ): YArgsParser{
    const syntax: Array<string> = name.split(/\s/);

    const command: Command = {
      names: [syntax[0], ...(aliases || [])],
      description: describe, options: [],
      arguments: syntax.slice(1).map((arg: string) => { // Parse <arg> or [arg] syntax
        const mo: RegExpMatchArray = arg.match(/^([<[])(.+).$/);
        let argDescription: string = `MISSING: ${mo[2]}`;

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

        return {name: mo[2], description: argDescription, required: mo[1] === '<'};
      })
    };

    if(builder){ // Local options
      const local: YArgsParser = new YArgsParser();
      builder(local);
      command.options = local.options;
    }

    // Add the new command
    this.commands.push(command);

    return this;
  }

  option(short: string, {alias: long, describe: description, demandOption: wantsArg}: {alias: string, describe: string, demandOption: boolean}): YArgsParser{
    this.options.push({short, long, description, wantsArg});

    return this;
  }
}

const banner: string = `
#!/usr/bin/env fish
#
# This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

function __fishamnium_git_verify
  set cmd (commandline -opc)
  ~/.fishamnium/helpers/fishamnium autocomplete $argv -- $cmd
  return $status
end
`.trim();

const header: string = 'complete -c g -c fishamnium';

const printOption = function(option: Option, condition: string, manager: 'bookmarks' | 'git', short: 'b' | 'g'): string{
  return format(
    '%s -n "__fishamnium_autocomplete_verify %s#%s%s" %s -s %s -l %s -d "%s"%s\n',
    header, manager, short,
    condition ? ` ${condition}` : '',
    option.wantsArg ? '-x' : '-f',
    option.short, option.long, option.description,
    option.long === 'remote' ? ' -a "(fishamnium g lr -a)"' : ''
  ).replace(/'/g, "\\'");
};

const printArgument = function(command: Command, condition: string, manager: 'bookmarks' | 'git', short: 'b' | 'g'): string{
  return format(
    'ATG:%s -n "__fishamnium_autocomplete_verify %s#%s%s" %s -a "%s" -d "%s"\n',
    header, manager, short,
    condition ? ` ${condition}` : '',
    command.arguments.length ? '-x' : '-f',
    command.names.join(' '),
    command.description
  );
};

const addManager = function(manager: (y: Argv) => Argv, managerSection: 'bookmarks' | 'git', short: 'b' | 'g'): string{
  let output: string = `complete -c ${short} -e\n`;
  const wrapper: YArgsParser = new YArgsParser();
  manager(wrapper as any);

  // Global options
  for(const opt of wrapper.options)
    output += printOption(opt, '', managerSection, short);

  // Commands
  for(const command of wrapper.commands){
    output += printArgument(command, '', managerSection, short);

    // Local options
    for(const opt of command.options){
      output += printOption(opt, command.names.join('#'), managerSection, short);
    }
  }

  return output + '\n';
};

const execute = function(): void{
  let output: string = `${banner}\n\ncomplete -c fishamnium -e\n`;

  output += addManager(buildBookmarksManager, 'bookmarks', 'b');
  output += addManager(buildGitManager, 'git', 'g');

  writeFileSync('./src/completions/71_fishamnium_git.fish', output, {encoding: 'utf8'});
  console.log(output);
};

execute();
