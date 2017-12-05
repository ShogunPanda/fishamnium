import {promisify} from 'util';
import {ChildProcess, exec as cpExec, spawn} from 'child_process';
import {Arguments} from 'yargs';
import chalk from 'chalk';
import argsplit from 'argsplit';

import {success, fail} from '../../utils/console';

export interface Result{
  stdout: string;
  stderr: string;
}

export interface Execution extends Result{
  status: number;
}

export const exec: (args: string) => Promise<Result> = promisify(cpExec);

export function complete(): void{
  success('All operations completed successfully!');
}

export function stepCompleted(): void{
  success('Exited with status 0.', true, true, '\u{1F4AC}');
}

export function stepFailed(code: number): void{
  fail(`Exited with status ${code}.`, true, null, '\u{1F4AC}');
}

export function wrapOutput(output: string): string{
  const indent = '\u0020\u0020\u0020';

  return output.replace(/(^.)/mg, `${indent}$1`);
}

export function handleReadOutput(output: any, standalone: boolean): string{
  if(standalone){
    console.log(output);

    return '';
  }

  return output;
}

export function executeCommand(command: string, args: string): Promise<Execution>{
  const execution: ChildProcess = spawn(command, argsplit(args), {stdio: 'pipe'});

  return new Promise<Execution>((resolve: (e: Execution) => void) => {
    // Create buffers
    let stdout: string = '';
    let stderr: string = '';

    // For stdout and stderr, both write to terminal and buffer for return value
    execution.stdout.on('data', (data: Buffer) => {
      const dataString: string = data.toString('utf8');
      process.stdout.write(wrapOutput(dataString));
      stdout += dataString;
    });

    execution.stderr.on('data', (data: Buffer) => {
      const dataString: string = data.toString('utf8');
      process.stderr.write(wrapOutput(dataString));
      stderr += dataString;
    });

    // When done, return with all informations
    execution.on('close', (status: number) => resolve({status, stdout, stderr}));
  });
}

export async function git(readOnly: boolean, cliArgs: Arguments, ...gitArgs: Array<string>): Promise<Execution>{
  try{
    const cmdline: string = `${gitArgs.join(' ')}`;
    const showOutput: boolean = !readOnly && cliArgs && !cliArgs.quiet;
    let result: Execution = {status: 0, stdout: '', stderr: ''};

    // Debugging
    if(cliArgs){
      if(!cliArgs.quiet)
        console.log(chalk`{yellow ${'\u{1F4AC}'}\u0020 ${cliArgs.dryRun ? 'Will execute' : 'Executing'}: {bold git ${cmdline}}}`);

      if(!readOnly && cliArgs.dryRun)
        return result;
    }

    // If not reading and not quiet, use full mode, otherwise a simpler interface
    result = {...result, ...(await (showOutput ? executeCommand('git', cmdline) : exec(`git ${cmdline}`)))};

    if(showOutput)
      result.status === 0 ? stepCompleted() : stepFailed(result.status);

    return result;
  }catch(e){
    return {status: e.code, stdout: e.stdout, stderr: e.stderr};
  }
}

export async function gitChain(readOnly: boolean, cliArgs: Arguments, chain: string | Array<string>): Promise<void | string>{
  if(!Array.isArray(chain))
    chain = [chain];

  for(const args of chain){
    // Execute the command
    const result: Execution = await git(readOnly, cliArgs, args);

    if(result.status !== 0)
      return fail(`One of operations failed with code ${result.status}.`, true, result.status);
  }
}

export async function readFromGit(...gitArgs: Array<string>): Promise<Execution>{
  return git(true, null, ...gitArgs);
}

export async function isRepository(_: Arguments = null, standalone: boolean = false, fatal: boolean = true): Promise<string | boolean | void>{
  // Execute command
  const result: Execution = await readFromGit('rev-parse --is-inside-work-tree');
  const inside: boolean = result.status === 0;

  // Return output
  if(standalone)
    return console.log(inside);
  else if(!inside && fatal)
    fail("You're not inside a git repository.");

  return inside;
}
