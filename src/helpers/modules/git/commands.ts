import {writeFileSync, unlinkSync} from 'fs';
import {Arguments} from 'yargs';
import chalk from 'chalk';

import {configuration} from './configuration';
import {fail} from '../../utils/console';
import {Execution, handleReadOutput, isRepository, git, gitChain, readFromGit, complete} from './execution';

const taskMatcher: RegExp = new RegExp(
  '^(?:' +
  '(?:((?:[a-z#]+-)?\\d+)-{1,2})?' + // Task in the prefix
  '(?:.+?)' + // Task subject
  '(?:-{1,2}((?:[a-z#]+-)?\\d+))?' + // Task in the suffix
  ')$',
  'i'
);

export async function isDirty(standalone: boolean = false): Promise<string>{
  // Execute command
  const result: Execution = await readFromGit('status -s');
  const dirty: boolean = result.stdout.length !== 0;

  return handleReadOutput(dirty, standalone);
}

export async function showRemotes(args: Arguments = null): Promise<void>{
  interface Remotes{
    [key: string]: string | {fetch: string, push: string};
  }

  // Execute command
  const result: Execution = await readFromGit('remote -v');

  // Parse output
  const remotes = result.stdout.trim().split('\n').reduce<Remotes>((accu: Remotes, line: string) => {
    const [name, url]: Array<string> = line.split(/\s+/);

    if(!accu[name]) // Add the remote
      accu[name] = url;
    else if(accu[name] !== url) // There is also a push url different from fetch
      (accu as any)[name] = {fetch: accu[name], push: url};

    return accu;
  }, {});

  if(args.autocomplete){
    for(const r of Object.keys(remotes)){
      const remote: any = (remotes as any)[r];
      console.log(`${r}\t${remote.fetch || remote}`);
    }
  }else{
    // Show as JSON
    console.log(JSON.stringify(remotes, null, 2));
  }
}

export async function branchName(_: Arguments = null, standalone = false, short = true): Promise<string>{
  // Execute some commands to get the name
  let result: Execution = await readFromGit('symbolic-ref HEAD');

  if(result.status !== 0)
    result = await readFromGit('rev-parse --short HEAD');

  // Check results
  if(result.status !== 0)
    return standalone ? fail('Cannot get git branch name.') : null;

  // Get the name and shorten it if needed
  let name = result.stdout.trim();

  if(short)
    name = name.replace('refs/heads/', '');

  // Show output
  return handleReadOutput(name, standalone);
}

export async function fetchSha(_: Arguments = null, standalone = false, short = true): Promise<string>{
  // Execute command
  const result: Execution = await readFromGit(`rev-parse ${short ? '--short' : ''} HEAD`);

  // Check results
  if(result.status !== 0)
    return standalone ? fail('Cannot get git SHA.') : null;

  const sha: string = result.stdout.trim();

  // Show output
  return handleReadOutput(sha, standalone);
}

export async function summary(_: Arguments = null): Promise<void | string>{
  if(!await isRepository(null, false))
    return null;

  return console.log([await branchName(), await fetchSha(), await isDirty()].join(' '));
}

export async function fetchTask(_: Arguments = null, standalone = false): Promise<string>{
  // Get the branch name
  const bn = await branchName(null, false);

  if(!bn)
    return standalone ? fail('Cannot get task name.') : null;

  // Find the task portion
  const mo: RegExpMatchArray = bn.split('/').pop().match(taskMatcher);
  const task: string =  mo[1] || mo[2] || null;

  // Return output
  return handleReadOutput(task, standalone);
}

export async function commitWithTask(args: Arguments, addAll: boolean, showCompletion: boolean = true): Promise<void>{
  let message: string = args.message;
  const task: string = args.task || await fetchTask();

  if(task)
    message = configuration.prependTask ? `[#${task}] ${message}` : `${message} [#${task}]`;

  // Write the commit message to a file
  const commitPath = `/tmp/fishamnium-git-commit-${new Date().getTime()}.txt`;
  try{
    writeFileSync(commitPath, message, 'utf8');
  }catch(e){
    fail(chalk`Cannot write temporary commit file {bold ${commitPath}}.`);
  }

  // Perform the command then delete the temp file
  const chain: Array<string> = [`commit -F ${commitPath}`];

  if(addAll)
    chain.unshift('add -A');
  await gitChain(false, args, chain);

  unlinkSync(commitPath);

  if(showCompletion)
    complete();
}

export async function reset(args: Arguments): Promise<void>{
  await gitChain(false, args, ['reset --hard', 'clean -f']);
  complete();
}

export async function cleanup(args: Arguments): Promise<void>{
  // Get branches
  const result: Execution = await readFromGit('branch --merged');

  if(result.status !== 0)
    fail('Cannot get git branches.');

  // Filter branches
  const filteredBranchs: Set<string> = new Set<string>(['master', '', await branchName(null, false, true)]);
  const branches: Array<string> = result.stdout.trim().split('\n').map(b => b.replace(/^\s*\*/, '').trim()).filter(b => !filteredBranchs.has(b));

  if(branches.length)
    await git(false, args, `branch -D ${branches.join(' ')}`);

  complete();
}

export async function update(args: Arguments): Promise<void>{
  const branch: string = args.branch || configuration.defaultBranch;
  const remote: string = args.remote || configuration.defaultRemote;

  await gitChain(false, args, [`fetch ${remote}`, `pull ${remote} ${branch}`]);
  complete();
}

export async function push(args: Arguments): Promise<void>{
  const branch: string = args.branch || await branchName(args, false, true);
  const remote: string = args.remote || configuration.defaultRemote;
  const force: boolean = args.force;

  await gitChain(false, args, `push ${force ? ' -f' : ''}${remote} ${branch}`);
  complete();
}

export async function deleteBranches(args: Arguments, branchesToDelete: Array<string> = null): Promise<void>{
  const branches: Array<string> = branchesToDelete || args.branch;
  const remote: string = args.remote || configuration.defaultRemote;

  if(branches.length){
    // Not using gitChain since commands are independent
    await git(false, args, `branch -D ${branches.join(' ')}`);
    await git(false, args, `push ${remote} ${branches.map((b: string) => `:${b}`).join(' ')}`);
  }

  if(!branchesToDelete)
    complete();
}
