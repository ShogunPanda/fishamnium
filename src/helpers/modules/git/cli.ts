import {Argv, Arguments, CommandBuilder} from 'yargs';

import {isDirty, showRemotes, branchName, fetchSha, summary, fetchTask, commitWithTask, reset, cleanup, update, push, deleteBranches} from './commands';
import {loadConfiguration, configuration} from './configuration';
import {isRepository} from './execution';
import {
  workflowStart, workflowRefresh, workflowFinish, workflowFastCommit, workflowPullRequest, workflowFastPullRequest, workflowTagRelease, workflowImport,
  workflowReleaseStart, workflowReleaseRefresh, workflowReleaseFinish, workflowReleaseImport, workflowReleaseDelete
} from './workflow';

type Handler = (args?: Arguments, ...otherArgs: Array<any>) => Promise<any>;

const sanityCheck = function(handler: Handler, ...otherArgs: Array<any>): Handler{
  return async (args: Arguments) => {
    if(await isRepository())
      return handler(args, ...otherArgs);
  };
};

export function buildGitManager(y: Argv){
  // First of all, load the configuration - Try to load the file starting here to the parent directorys
  loadConfiguration();

  const remoteOption: CommandBuilder = (ly: Argv) => (
    ly.option('r', {alias: 'remote', describe: 'The remote to act on.', default: configuration.defaultRemote, type: 'string', demandOption: true})
  );

  const prefixOption: CommandBuilder = (ly: Argv) => (
    ly.option('p', {alias: 'prefix', describe: 'The prefix to use.', default: configuration.defaultPrefix, type: 'string', demandOption: true})
  );

  const temporaryOption: CommandBuilder = (ly: Argv) => (
    ly.option('t', {alias: 'temporary', describe: 'Name of the temporary branch.', default: '', type: 'string', demandOption: true})
  );

  const forceOption: CommandBuilder = (ly: Argv) => (ly.option('f', {alias: 'force', describe: 'If to perform a force push.', type: 'boolean'}));

  const standardOption: CommandBuilder = (ly: Argv) => prefixOption(remoteOption(ly));

  return y
    // Read commands
    // .command({command: 'autocomplete', describe: 'Generates autocompletion for fish shell.', handler: () => false})
    .option('q', {alias: 'quiet', describe: 'Be more quiet.', type: 'boolean'})
    .option('n', {alias: 'dry-run', describe: 'Do not execute write action.', type: 'boolean'})
    .command({
      command: 'is_repository', aliases: ['ir'], describe: 'Check if the current directory is a GIT repository.',
      handler: isRepository.bind(null, true)
    })
    .command({
      command: 'is_dirty', aliases: ['id'], describe: 'Check if the current GIT repository has uncommitted changes.',
      handler: isDirty.bind(null, true)
    })
    .command({
      command: 'remotes', aliases: ['lr'], describe: 'Show GIT remotes.',
      builder: (ly: Argv) => (ly.option('a', {alias: 'autocomplete', describe: 'Format for autocompletion.', type: 'boolean'})),
      handler: sanityCheck(showRemotes)
    })
    .command({command: 'full_branch_name', aliases: ['fbn'], describe: 'Get the full current branch name.', handler: sanityCheck(branchName, true, false)})
    .command({command: 'branch_name', aliases: ['bn'], describe: 'Get the current branch name.', handler: sanityCheck(branchName, true)})
    .command({command: 'full_sha', describe: 'Get the full current GIT SHA.', handler: sanityCheck(fetchSha, true, false)})
    .command({command: 'sha', describe: 'Get the current GIT SHA.', handler: sanityCheck(fetchSha, true)})
    .command({command: 'summary', aliases: ['ls'], describe: 'Get a summary of current GIT repository branch, SHA and dirty status.', handler: summary})
    .command({command: 'task', aliases: ['t'], describe: 'Get the current task name from the branch name.', handler: sanityCheck(fetchTask, true)})
    // Write commands
    .command({
      command: 'commit_with_task <message> [task]', aliases: ['ct'], describe: 'Commit changes including the task name.',
      handler: sanityCheck(commitWithTask)
    })
    .command({
      command: 'commit_all_with_task <message> [task]', aliases: ['cat'], describe: 'Commit all changes including the task name.',
      builder: (ly: Argv) => (ly.option('a', {alias: 'add-all', describe: 'Add all files before commiting.', type: 'boolean'})),
      handler: sanityCheck(commitWithTask, true)
    })
    .command({command: 'reset', aliases: ['re'], describe: 'Reset all uncommitted changes.', handler: sanityCheck(reset)})
    .command({command: 'cleanup', aliases: ['cl'], describe: 'Deletes all non default branches.', handler: sanityCheck(cleanup)})
    .command({
      command: 'update [branch]', aliases: ['u'], describe: 'Fetch from remote and pulls a a branch.',
      builder: remoteOption, handler: sanityCheck(update)
    })
    .command({
      command: 'push [branch]', aliases: ['p'], describe: 'Pushes the current branch to the remote.',
      builder: (ly: Argv) => forceOption(remoteOption(ly)), handler: sanityCheck(push)
    })
    .command({
      command: 'delete <branch...>', aliases: ['d'], describe: 'Deletes one or more branch both locally and on a remote.',
      builder: remoteOption, handler: sanityCheck(deleteBranches)
    })
    .command({
      command: 'start <branch> [base]', aliases: ['s'], describe: 'Starts a new branch out of the base one.',
      builder: remoteOption, handler: sanityCheck(workflowStart)
    })
    .command({
      command: 'refresh [base]', aliases: ['r'], describe: 'Rebases the current branch on top of an existing remote branch.',
      builder: remoteOption, handler: sanityCheck(workflowRefresh)
    })
    .command({
      command: 'finish [base]', aliases: ['f'], describe: 'Merges a branch back to its base remote branch.',
      builder: remoteOption, handler: sanityCheck(workflowFinish)
    })
    .command({
      command: 'full_finish [base]', aliases: ['ff'], describe: 'Merges a branch back to its base remote branch and then deletes the local copy.',
      builder: remoteOption, handler: sanityCheck(workflowFinish, true)
    })
    .command({
      command: 'fast_commit <branch> <message> [base]', aliases: ['fc'],
      describe: 'Creates a local branch, commit changes and then merges it back to the base branch.',
      builder: remoteOption, handler: sanityCheck(workflowFastCommit)
    })
    .command({
      command: 'pull_request [base]', aliases: ['pr'], describe: 'Sends a Pull Request and deletes the local branch.',
      builder: remoteOption, handler: sanityCheck(workflowPullRequest)
    })
    .command({
      command: 'fast_pull_request <branch> <message> [base]', aliases: ['fpr'],
      describe: 'Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end.',
      builder: remoteOption, handler: sanityCheck(workflowFastPullRequest)
    })
    .command({
      command: 'release <spec> [base]', aliases: ['rt'], describe: 'Tags and pushes a new release branch out of the base one.',
      builder: standardOption, handler: sanityCheck(workflowTagRelease)
    })
    .command({
      command: 'import <source> [destination]', aliases: ['i'], describe: 'Imports latest changes to a local branch on top of an existing remote branch.',
      builder: (ly: Argv) => temporaryOption(remoteOption(ly)), handler: sanityCheck(workflowImport)
    })
    .command({
      command: 'start_from_release <branch> <spec>', aliases: ['rs'], describe: 'Starts a new branch out of a remote release branch.',
      builder: standardOption, handler: sanityCheck(workflowReleaseStart)
    })
    .command({
      command: 'refresh_from_release <spec>', aliases: ['rr'], describe: 'Rebases the current branch on top of an existing remote release branch.',
      builder: standardOption, handler: sanityCheck(workflowReleaseRefresh)
    })
    .command({
      command: 'finish_to_release <spec>', aliases: ['rf'], describe: 'Merges a branch back to its base remote release branch.',
      builder: standardOption, handler: sanityCheck(workflowReleaseFinish)
    })
    .command({
      command: 'full_finish_to_release <spec>', aliases: ['rff'],
      describe: 'Merges a branch back to its base remote release branch and then deletes the local copy.',
      builder: standardOption, handler: sanityCheck(workflowReleaseFinish, true)
    })
    .command({
      command: 'import_release <spec> [destination]', aliases: ['ri'],
      describe: 'Imports latest changes to a local branch on top of an existing remote release branch.',
      builder: (ly: Argv) => temporaryOption(standardOption(ly)), handler: sanityCheck(workflowReleaseImport)
    })
    .command({
      command: 'delete_release <spec>', aliases: ['rd'], describe: 'Deletes a release branch locally and remotely.',
      builder: standardOption, handler: sanityCheck(workflowReleaseDelete)
    })
  ;
}
