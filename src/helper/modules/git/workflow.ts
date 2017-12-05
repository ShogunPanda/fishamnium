import {Arguments} from 'yargs';
import chalk from 'chalk';
import {exec} from 'child_process';

import {branchName, commitWithTask, deleteBranches} from './commands';
import {configuration} from './configuration';
import {debug, fail} from '../../utils/console';
import {Execution, complete, gitChain, git} from './execution';

export async function workflowDebug(message: string): Promise<void | string>{
  if(configuration.quiet)
    return;

  return debug(`Workflow: ${message}`);
}

export async function workflowStart(args: Arguments, destination: string = null, source: string = null): Promise<void>{
  // Parse arguments
  const branch: string = destination || args.branch;
  const base: string = source || args.base || configuration.defaultBranch;
  const remote: string = args.remote || configuration.defaultRemote;

  // Execute commands
  workflowDebug(chalk`Creating a new branch {yellow ${branch}} using base branch {yellow ${base}} on remote {yellow ${remote}} ...`);
  await gitChain(false, args, [`fetch ${remote}`, `checkout ${base}`, `pull ${remote} ${base}`, `checkout -b ${branch}`]);

  if(!destination)
    complete();
}

export async function workflowRefresh(args: Arguments, destination: string = null, source: string = null): Promise<void>{
  // Parse arguments
  const branch: string = destination || await branchName(args, false, true);
  const base: string = source || args.base || configuration.defaultBranch;
  const remote: string = args.remote || configuration.defaultRemote;

  // Sanity check
  if(branch === base)
    fail('You are already on the base branch.');

  // Execute commands
  if(!destination)
    workflowDebug(chalk`Refreshing current branch {yellow ${branch}} on top of base branch {yellow ${base}} on remote {yellow ${remote}} ...`);
  await gitChain(false, args, [`fetch ${remote}`, `checkout ${base}`, `pull ${remote} ${base}`, `checkout ${branch}`, `rebase ${base}`]);

  if(!destination)
    complete();
}

export async function workflowFinish(
  args: Arguments, deleteAfter: boolean = false, source: string = null, destination: string = null, showCompletion: boolean = true
): Promise<void>{
  // Parse arguments
  const branch: string = source || await branchName(args, false, true);
  const base: string = destination || args.base || configuration.defaultBranch;
  const remote: string = args.remote || configuration.defaultRemote;

  // Sanity check
  if(branch === base)
    fail('You are already on the base branch.');

  // Debug info
  workflowDebug(chalk`Merging current branch {yellow ${branch}} to the base branch {yellow ${base}} on remote {yellow ${remote}} ...`);

  if(deleteAfter)
    workflowDebug(chalk`After merging, the new current branch will be {yellow ${base}} and the current branch {yellow ${branch}} will be deleted.`);

  // Refresh branch
  await workflowRefresh(args, branch, base);

  // Prepare commands
  const commands: Array<string> = [
    `checkout ${base}`,
    `merge --no-ff --no-edit ${branch}`
  ];

  if(deleteAfter)
    commands.push(`branch -D ${branch}`);

  // Execute commands
  await gitChain(false, args, commands);

  if(showCompletion)
    complete();
}

export async function workflowFastCommit(args: Arguments): Promise<void>{
  // Parse arguments
  const message: string = args.message;

  // Execute commands
  await workflowStart(args, args.branch);
  workflowDebug(`Committing all changes with message: "${message}" ...`);
  await commitWithTask(args, true, false);
  await workflowFinish(args, true, args.branch);
}

export async function workflowTagRelease(args: Arguments): Promise<void>{
  // Parse arguments
  const prefix: string = args.prefix || configuration.defaultPrefix;
  const release: string = args.branch = `${prefix}${args.spec}`;
  const current: string = await branchName(args, false, true);
  const remote: string = args.remote || configuration.defaultRemote;

  // Execute commands
  await workflowStart(args);
  workflowDebug(chalk`Pushing release tag {yellow ${release}} to the remote {yellow ${remote}} and then deleting the local branch...`);
  await gitChain(false, args, [`push -f ${remote} ${release}`, `checkout ${current}`, `branch -D ${release}`]);
  complete();
}

export async function workflowImport(args: Arguments): Promise<void>{
  // Parse arguments
  const source: string = args.source;
  const destination: string = args.destination || await branchName(args, false, true);
  const temporary: string = args.temporary || `import-${source}`;
  const remote: string = args.remote || configuration.defaultRemote;

  // Execute commands
  workflowDebug(chalk`Deleting eventually existing branch {yellow ${temporary}} ...`);
  await deleteBranches(args, [temporary]);
  await workflowStart(args, temporary, source);
  await workflowFinish(args, true, temporary, destination, false);
  workflowDebug(chalk`Pushing updated branch {yellow ${destination}} to remote {yellow ${remote}} ...`);
  await gitChain(false, args, `push -f ${remote} ${destination}`);
  complete();
}

export async function workflowPullRequest(args: Arguments): Promise<void>{
  // Parse arguments
  const branch: string = args.branch || await branchName(args, false, true);
  const base: string = args.base || configuration.defaultBranch;
  const remote: string = args.remote || configuration.defaultRemote;

  // Sanity check
  if(branch === base)
    fail('You are already on the base branch.');

  workflowDebug(chalk`Creating a pull request from branch {yellow ${branch}} to base branch {yellow ${base}} on remote {yellow ${remote}} ...`);
  workflowDebug(chalk`After creation, the new current branch will be {yellow ${base}} and the current branch {yellow ${branch}} will be deleted..`);

  // Refresh branch
  await workflowRefresh(args, branch, base);

  // Push branch
  const output: Execution = await git(false, args, `push -f ${remote} ${branch}`);
  await gitChain(false, args, [`checkout ${base}`, `branch -D ${branch}`]);

  // Find the PR url
  const url: string = output.stderr.trim().split('\n')
    .map((line: string) => {
      line = line.replace('remote: ', '').trim();

      if(line.match(/^(?:To github\.com:(.+)\.git)$/)) // Fix for Github
        line = `https://github.com/${RegExp.$1}/compare/${base}...${branch}?expand=1`;

      return line;
    })
    .find((line: string) => (
      (line.startsWith('https://gitlab.com/') && line.includes('/merge_requests/new')) || // GitLab
      (line.startsWith('https://github.com/') && line.includes('/compare')) || // GitHub
      (line.includes('/compare/commits?sourceBranch=')) // JIRA
    ));

  if(url){
    // Open the URL
    workflowDebug(chalk`Opening URL {yellow ${url}} to finalize the Pull Request creation ...`);
    await exec(`${configuration.openPath} "${url}"`);
  }else
    fail('Could not detect a Pull Request creation URL after pushing. Please create the Pull Request on the remote website manually.', true, null);

  complete();
}

export async function workflowFastPullRequest(args: Arguments): Promise<void>{
  // Parse arguments
  const message: string = args.message;

  // Execute commands
  await workflowStart(args, args.branch);
  workflowDebug(`Committing all changes with message: "${message}" ...`);
  await commitWithTask(args, true, false);
  await workflowPullRequest(args);
}

export async function workflowReleaseStart(args: Arguments): Promise<void>{
  // Parse arguments
  args.base = `${args.prefix || configuration.defaultPrefix}${args.spec}`;

  // Execute commands
  return workflowStart(args);
}

export async function workflowReleaseRefresh(args: Arguments): Promise<void>{
  // Parse arguments
  args.base = `${args.prefix || configuration.defaultPrefix}${args.spec}`;

  // Execute commands
  return workflowRefresh(args);
}

export async function workflowReleaseFinish(args: Arguments, deleteAfter: boolean = false): Promise<void>{
  // Parse arguments
  args.base = `${args.prefix || configuration.defaultPrefix}${args.spec}`;

  // Execute commands
  return workflowFinish(args, deleteAfter);
}

export async function workflowReleaseImport(args: Arguments): Promise<void>{
  // Parse arguments
  args.source = `${args.prefix || configuration.defaultPrefix}${args.spec}`;

  // Execute commands
  return workflowImport(args);
}

export async function workflowReleaseDelete(args: Arguments): Promise<void>{
  // Parse arguments
  args.branch = [`${args.prefix || configuration.defaultPrefix}${args.spec}`];

  // Execute commands
  deleteBranches(args);
}
