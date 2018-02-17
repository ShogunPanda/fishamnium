/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package git

import (
	"github.com/spf13/cobra"
)

func addSubcommand(parent, cmd *cobra.Command, optionsHook func(cmd *cobra.Command)) {
	parent.AddCommand(cmd)

	if optionsHook != nil {
		optionsHook(cmd)
	}
}

func addStandardOptions(cmd *cobra.Command) {
	cmd.Flags().StringP("prefix", "p", configuration.DefaultPrefix, "The prefix to use.")
}

func getPositionalArgument(args []string, index int, def string) string {
	if len(args) <= index {
		return def
	}

	return args[index]
}

func getStringOption(cmd *cobra.Command, name, def string) (option string) {
	option, _ = cmd.Flags().GetString(name)

	if option == "" {
		option = def
	}

	return
}

func getPrefixOption(cmd *cobra.Command) (remote string) {
	return getStringOption(cmd, "prefix", configuration.DefaultPrefix)
}

func getRemoteOption(cmd *cobra.Command) (remote string) {
	return getStringOption(cmd, "remote", configuration.DefaultRemote)
}

// InitCLI setups the GIT module
func InitCLI() *cobra.Command {
	parent := &cobra.Command{Use: "git", Short: "Manage GIT Repositories."}

	parent.PersistentFlags().StringP("remote", "r", configuration.DefaultRemote, "The remote to act on.")
	parent.PersistentFlags().BoolP("quiet", "q", false, "Be more quiet.")
	parent.PersistentFlags().BoolP("dry-run", "n", false, "Do not execute write action.")

	// Read commands
	addSubcommand(parent, &cobra.Command{
		Use: "is-repository", Aliases: []string{"ir"}, Short: "Check if the current directory is a GIT repository.", Run: IsRepository,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "is_dirty", Aliases: []string{"id"}, Short: "Check if the current GIT repository has uncommitted changes.", Run: IsDirty,
	}, nil)

	addSubcommand(parent, &cobra.Command{Use: "remotes", Aliases: []string{"lr"}, Short: "Show GIT remotes.", Run: ShowRemotes}, func(cmd *cobra.Command) {
		cmd.Flags().BoolP("autocomplete", "a", false, "Only list remotes name and description for autocompletion.")
	})

	addSubcommand(parent, &cobra.Command{Use: "full_branch_name", Aliases: []string{"fbn"}, Short: "Get the full current branch name.", Run: FullBranchName}, nil)
	addSubcommand(parent, &cobra.Command{Use: "branch_name", Aliases: []string{"bn"}, Short: "Get the current branch name.", Run: BranchName}, nil)
	addSubcommand(parent, &cobra.Command{Use: "full_sha", Short: "Get the full current GIT SHA.", Run: FullSha}, nil)
	addSubcommand(parent, &cobra.Command{Use: "sha", Short: "Get the current GIT SHA.", Run: Sha}, nil)
	addSubcommand(parent, &cobra.Command{Use: "task", Aliases: []string{"t"}, Short: "Get the current task name from the branch name.", Run: Task}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "summary", Aliases: []string{"ls"}, Short: "Get a summary of current GIT repository branch, SHA and dirty status.", Run: Summary,
	}, nil)

	// Write commands
	addSubcommand(parent, &cobra.Command{
		Use: "commit_with_task <message> [task]", Aliases: []string{"ct"}, Args: cobra.RangeArgs(1, 2),
		Short: "Commit changes including the task name.", Run: CommitWithTask,
	}, nil)

	addSubcommand(parent, &cobra.Command{
		Use: "commit_all_with_task <message> [task]", Aliases: []string{"cat"},
		Short: "Commit all changes including the task name.", Args: cobra.RangeArgs(1, 2), Run: CommitAllWithTask,
	}, nil)

	addSubcommand(parent, &cobra.Command{
		Use: "push [branch]", Aliases: []string{"p"}, Short: "Pushes the current branch to the remote.", Args: cobra.MaximumNArgs(1), Run: Push,
	}, func(cmd *cobra.Command) {
		cmd.Flags().BoolP("force", "f", false, "Perform a forced push.")
	})

	addSubcommand(parent, &cobra.Command{Use: "reset", Aliases: []string{"re"}, Short: "Reset all uncommitted changes.", Run: Reset}, nil)

	addSubcommand(parent, &cobra.Command{
		Use: "update [branch]", Aliases: []string{"u"}, Short: "Fetch from remote and pulls a a branch.", Args: cobra.MaximumNArgs(1), Run: Update,
	}, nil)

	addSubcommand(parent, &cobra.Command{
		Use: "delete <branch...>", Aliases: []string{"d"},
		Short: "Deletes one or more branch both locally and on a remote.", Args: cobra.MinimumNArgs(1), Run: Delete,
	}, nil)

	addSubcommand(parent, &cobra.Command{Use: "cleanup", Aliases: []string{"cl"}, Short: "Deletes all non default branches.", Run: Cleanup}, nil)

	// Workflow
	addSubcommand(parent, &cobra.Command{
		Use: "start <branch> [base]", Aliases: []string{"s"}, Args: cobra.RangeArgs(1, 2),
		Short: "Starts a new branch out of the base one.", Run: WorkflowStart,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "refresh [base]", Aliases: []string{"r"}, Args: cobra.MaximumNArgs(1),
		Short: "Rebases the current branch on top of an existing remote branch.", Run: WorkflowRefresh,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "finish [base]", Aliases: []string{"f"}, Args: cobra.MaximumNArgs(1),
		Short: "Merges a branch back to its base remote branch.", Run: WorkflowFinish,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "full_finish [base]", Aliases: []string{"ff"}, Args: cobra.MaximumNArgs(1),
		Short: "Merges a branch back to its base remote branch and then deletes the local copy.", Run: WorkflowFullFinish,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "fast_commit <branch> <message> [base]", Aliases: []string{"fc"}, Args: cobra.RangeArgs(2, 3),
		Short: "Creates a local branch, commit changes and then merges it back to the base branch.", Run: WorkflowFastCommit,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "pull_request [base]", Aliases: []string{"pr"}, Args: cobra.MaximumNArgs(1),
		Short: "Sends a Pull Request and deletes the local branch.", Run: WorkflowPullRequest,
	}, nil)
	addSubcommand(parent, &cobra.Command{
		Use: "fast_pull_request <branch> <message> [base]", Aliases: []string{"fpr"}, Args: cobra.RangeArgs(2, 3),
		Short: "Creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end.", Run: WorkflowFastPullRequest,
	}, nil)

	addSubcommand(parent, &cobra.Command{
		Use: "release <spec> [base]", Aliases: []string{"rt"}, Args: cobra.RangeArgs(1, 2),
		Short: "Tags and pushes a new release branch out of the base one.", Run: WorkflowRelease,
	}, addStandardOptions)
	addSubcommand(parent, &cobra.Command{
		Use: "import <source> [destination]", Aliases: []string{"i"}, Args: cobra.RangeArgs(1, 2),
		Short: "Imports latest changes to a local branch on top of an existing remote branch.", Run: WorkflowImport,
	}, func(cmd *cobra.Command) {
		cmd.Flags().StringP("temporary", "t", "", "Name of the temporary branch.")
	})

	addSubcommand(parent, &cobra.Command{
		Use: "start_from_release <branch> <spec>", Aliases: []string{"rs"}, Args: cobra.ExactArgs(2),
		Short: "Starts a new branch out of a remote release branch.", Run: WorkflowStartRelease,
	}, addStandardOptions)

	addSubcommand(parent, &cobra.Command{
		Use: "refresh_from_release <spec>", Aliases: []string{"rr"}, Args: cobra.RangeArgs(1, 2),
		Short: "Rebases the current branch on top of an existing remote release branch.", Run: WorkflowRefreshRelease,
	}, addStandardOptions)

	addSubcommand(parent, &cobra.Command{
		Use: "finish_to_release <spec>", Aliases: []string{"rf"}, Args: cobra.RangeArgs(1, 2),
		Short: "Merges a branch back to its base remote release branch.", Run: WorkflowFinishRelease,
	}, addStandardOptions)

	addSubcommand(parent, &cobra.Command{
		Use: "full_finish_to_release <spec>", Aliases: []string{"rff"}, Args: cobra.RangeArgs(1, 2),
		Short: "Merges a branch back to its base remote release branch and then deletes the local copy.", Run: WorkflowFullFinishRelease,
	}, addStandardOptions)

	addSubcommand(parent, &cobra.Command{
		Use: "import_to_release <spec> [destination]", Aliases: []string{"ri"}, Args: cobra.RangeArgs(1, 2),
		Short: "Imports latest changes to a local branch on top of an existing remote release branch.", Run: WorkflowImportRelease,
	}, func(cmd *cobra.Command) {
		addStandardOptions(cmd)
		cmd.Flags().StringP("temporary", "t", "", "Name of the temporary branch.")
	})

	addSubcommand(parent, &cobra.Command{
		Use: "delete_release <spec>", Aliases: []string{"rd"}, Args: cobra.MinimumNArgs(1),
		Short: "Deletes a release branch locally and remotely.", Run: WorkflowDeleteRelease,
	}, addStandardOptions)

	return parent
}
