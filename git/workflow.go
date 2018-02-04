/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit/.
 */

package git

import (
	"fmt"
	"os/exec"

	"github.com/spf13/cobra"

	"github.com/ShogunPanda/fishamnium/console"
)

func workflowDebug(message string, args ...interface{}) {
	console.Debug(fmt.Sprintf("Workflow: %s", message), args...)
}

func workflowStart(branch, base, remote string) {
	// Show message
	workflowDebug("Creating a new branch {yellow}%s{-} using base branch {yellow}%s{-} on remote {yellow}%s{-} ...", branch, base, remote)

	// Perform operations
	gitChain(false, [][]string{
		[]string{"fetch", remote},
		[]string{"checkout", base},
		[]string{"pull", remote, base},
		[]string{"checkout", "-b", branch},
	})
}

func workflowRefresh(branch, base, remote string) {
	if branch == base {
		console.Fatal("You are already on the base branch. Use the {yellow}update{-} command.")
	}

	// Show message
	workflowDebug("Refreshing current branch {yellow}%s{-} on top of base branch {yellow}%s{-} on remote {yellow}%s{-} ...", branch, base, remote)

	// Perform operations
	gitChain(false, [][]string{
		[]string{"fetch", remote},
		[]string{"checkout", base},
		[]string{"pull", remote, base},
		[]string{"checkout", branch},
		[]string{"rebase", base},
	})
}

func workflowFinish(branch, base, remote string, deleteAfter bool) {
	if branch == base {
		console.Fatal("You are already on the base branch.")
	}

	workflowRefresh(branch, base, remote)

	// Debug info
	workflowDebug("Merging current branch {yellow}%s{-} to the base branch {yellow}%s{-} on remote {yellow}%s{-} ...", branch, base, remote)

	chain := [][]string{
		[]string{"checkout", base},
		[]string{"merge", "--no-ff", "--no-edit", branch},
	}

	if deleteAfter {
		workflowDebug("After merging, the new current branch will be {yellow}%s{-} and the current branch {yellow}%s{-} will be deleted.", base, branch)

		chain = append(chain, []string{"branch", "-D", branch})
	}

	gitChain(false, chain)
}

func workflowPullRequest(branch, base, remote string) {
	if branch == base {
		console.Fatal("You are already on the base branch.")
	}

	workflowRefresh(branch, base, remote)

	// Debug info
	workflowDebug("Creating a pull request from current branch {yellow}%s{-} to the base branch {yellow}%s{-} on remote {yellow}%s{-} ...", branch, base, remote)
	workflowDebug("After merging, the new current branch will be {yellow}%s{-} and the current branch {yellow}%s{-} will be deleted.", base, branch)

	chain := [][]string{
		[]string{"push", "-f", remote, branch},
		//[]string{"branch", "-D", base},
	}

	// Perform operations to merge the branch, then find the PR URL
	results := gitChain(false, chain)

	if configuration.DryRun {
		return
	}

	prURL := buildPRURL(results[0].Stderr, base, branch)

	// If there is a URL, open it
	if prURL != "" {
		// Open the URL
		workflowDebug("Opening URL {yellow}%s{-} to finalize the Pull Request creation ...", prURL)
		exec.Command(configuration.OpenPath, prURL).Run()
	} else {
		console.Fail("Could not detect a Pull Request creation URL after pushing. Please create the Pull Request on the remote website manually.")
	}
}

// WorkflowStart starts a new branch out of the base one
func WorkflowStart(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := args[0]
	base := getPositionalArgument(args, 1, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	// Perform operation
	workflowStart(branch, base, remote)
	console.Complete()
}

// WorkflowRefresh rebases the current branch on top of an existing remote branch
func WorkflowRefresh(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := branchName(false, true, false)
	base := getPositionalArgument(args, 0, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	// Perform operations
	workflowRefresh(branch, base, remote)
	console.Complete()
}

// WorkflowFinish merges a branch back to its base remote branch.
func WorkflowFinish(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := branchName(false, true, false)
	base := getPositionalArgument(args, 0, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	// Perform operations
	workflowFinish(branch, base, remote, false)
	console.Complete()
}

// WorkflowFullFinish merges a branch back to its base remote branch and then deletes the local copy.
func WorkflowFullFinish(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := branchName(false, true, false)
	base := getPositionalArgument(args, 0, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	// Perform operations
	workflowFinish(branch, base, remote, true)
	console.Complete()
}

// WorkflowFastCommit creates a local branch, commit changes and then merges it back to the base branch.
func WorkflowFastCommit(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := getPositionalArgument(args, 0, configuration.DefaultBranch)
	message := getPositionalArgument(args, 1, "")
	base := getPositionalArgument(args, 2, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	// Perform commands
	workflowStart(branch, base, remote)
	workflowDebug("Committing all changes with message: {yellow}\"%s\"{-} ...", message)
	commitWithTask([]string{message}, true, false)
	workflowFinish(branch, base, remote, true)
	console.Complete()
}

// WorkflowPullRequest sends a Pull Request and deletes the local branch.
func WorkflowPullRequest(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := branchName(false, true, false)
	base := getPositionalArgument(args, 0, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	workflowPullRequest(branch, base, remote)
	console.Complete()
}

// WorkflowFastPullRequest creates a local branch, commit changes and then sends a Pull Request, deleting the local branch at the end.
func WorkflowFastPullRequest(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	branch := getPositionalArgument(args, 0, configuration.DefaultBranch)
	message := getPositionalArgument(args, 1, "")
	base := getPositionalArgument(args, 2, configuration.DefaultBranch)
	remote := getRemoteOption(cmd)

	// Perform commands
	workflowStart(branch, base, remote)
	workflowDebug("Committing all changes with message: {yellow}\"%s\"{-} ...", message)
	commitWithTask([]string{message}, true, false)
	workflowPullRequest(branch, base, remote)
	console.Complete()
}

// WorkflowRelease tags and pushes a new release branch out of the base one.
func WorkflowRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	release := getPrefixOption(cmd) + args[0]
	current := branchName(false, true, false)
	base := getPositionalArgument(args, 1, current)
	remote := getRemoteOption(cmd)

	// Perform commands
	workflowStart(release, base, remote)
	workflowDebug("Pushing release branch {yellow}%s{-} to the remote {yellow}%s{-} and then deleting the local copy ...", release, remote)
	gitChain(false, [][]string{
		[]string{"push -f", remote, release},
		[]string{"checkout", current},
		[]string{"branch", "-D", release},
	})

	console.Complete()
}

// WorkflowImport imports latest changes to a local branch on top of an existing remote branch.
func WorkflowImport(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Parse arguments
	source := args[0]
	destination := getPositionalArgument(args, 1, "")
	temporary := getStringOption(cmd, "temporary", "import-"+source)
	remote := getRemoteOption(cmd)

	if destination == "" {
		destination = branchName(false, true, false)
	}

	// Perform commands
	workflowDebug("Deleting eventually existing local branch {yellow}%s{-} ...", temporary)
	deleteBranches(cmd, []string{temporary})
	workflowStart(temporary, source, remote)
	workflowFinish(temporary, destination, remote, true)
	workflowDebug("Pushing updated branch {yellow}%s{-} to remote {yellow}%s{-} ...", destination, remote)
	gitChain(false, [][]string{[]string{"push", "-f", remote, destination}})
	console.Complete()
}

// WorkflowStartRelease starts a new branch out of a remote release branch.
func WorkflowStartRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Convert arguments
	args[1] = getPrefixOption(cmd) + args[1]

	// Perform commands
	WorkflowStart(cmd, args)
}

// WorkflowRefreshRelease rebases the current branch on top of an existing remote release branch.
func WorkflowRefreshRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Convert arguments
	args[0] = getPrefixOption(cmd) + args[0]

	// Perform commands
	WorkflowRefresh(cmd, args)
}

// WorkflowFinishRelease merges a branch back to its base remote release branch.
func WorkflowFinishRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Convert arguments
	args[0] = getPrefixOption(cmd) + args[0]

	// Perform commands
	WorkflowFinish(cmd, args)
}

// WorkflowFullFinishRelease merges a branch back to its base remote release branch and then deletes the local copy.
func WorkflowFullFinishRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Convert arguments
	args[0] = getPrefixOption(cmd) + args[0]

	// Perform commands
	WorkflowFullFinish(cmd, args)
}

// WorkflowImportRelease imports latest changes to a local branch on top of an existing remote release branch.
func WorkflowImportRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Convert arguments
	args[0] = getPrefixOption(cmd) + args[0]

	// Perform commands
	WorkflowImport(cmd, args)
}

// WorkflowDeleteRelease deletes a release branch locally and remotely.
func WorkflowDeleteRelease(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	// Convert arguments
	for i := range args {
		args[i] = getPrefixOption(cmd) + args[i]
	}

	// Perform commands
	Delete(cmd, args)
}
