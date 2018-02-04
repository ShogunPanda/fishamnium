/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package git

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"

	"github.com/spf13/cobra"

	"github.com/ShogunPanda/fishamnium/console"
)

func prepareWriteCommand(cmd *cobra.Command) {
	if !configuration.DryRun {
		configuration.DryRun, _ = cmd.Flags().GetBool("dry-run")
	}

	if !configuration.Quiet {
		configuration.Quiet, _ = cmd.Flags().GetBool("quiet")
	}

	isRepository(true, false)
}

func commitWithTask(args []string, addAll bool, showMessage bool) {
	// Get arguments
	message := args[0]
	taskArg := ""

	// Add or prepend the task
	if len(args) > 1 {
		taskArg = args[1]
	} else {
		taskArg = task(true, false)
	}

	if taskArg != "" {
		if configuration.PrependTask {
			message = fmt.Sprintf("[#%s] %s", taskArg, message)
		} else {
			message = fmt.Sprintf("%s [#%s]", message, taskArg)
		}
	}

	if showMessage {
		console.Debug("Committing all changes with the message {yellow}\"%s\"{-}.", message)
	}

	// Write the commit message to a file
	tmpfile, err := ioutil.TempFile("", "fishamnium-git-commit-")
	if err != nil {
		console.Fatal("Cannot write the commit message to a temporary file.")
	}
	defer os.Remove(tmpfile.Name()) // Remove the file once done

	tmpfile.WriteString(message)

	// Now execute the chain
	var chain [][]string

	if addAll {
		chain = append(chain, []string{"add", "-A"})
	}

	chain = append(chain, []string{"commit", "-F", tmpfile.Name()})

	gitChain(false, chain)
}

func deleteBranches(cmd *cobra.Command, branches []string) {
	remote := getRemoteOption(cmd)

	// Do not use gitChain since commands are independent
	// Delete locally
	git(false, append([]string{"branch", "-D"}, branches...)...)

	var remoteBranches []string
	for _, branch := range branches {
		remoteBranches = append(remoteBranches, ":"+branch)
	}
	git(false, append([]string{"push", remote}, remoteBranches...)...)
}

// CommitWithTask commits changes with the task name
func CommitWithTask(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)
	commitWithTask(args, false, true)
	console.Complete()
}

// CommitAllWithTask commits all changes with the task name
func CommitAllWithTask(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)
	commitWithTask(args, true, true)
	console.Complete()
}

// Push pushes the current branch to the remote.
func Push(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	branch := ""
	remote := getRemoteOption(cmd)

	if len(args) > 0 {
		branch = args[0]
	} else {
		branch = branchName(false, true, false)
	}

	pushArgs := []string{"push", remote, branch}

	if force, _ := cmd.Flags().GetBool("force"); force {
		pushArgs = append(pushArgs[:1], append([]string{"-f"}, pushArgs[1:]...)...)
	}

	gitChain(false, [][]string{pushArgs})
	console.Complete()
}

// Update fetchs from remote and pulls a a branch.
func Update(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	branch := ""
	remote := getRemoteOption(cmd)

	if len(args) > 0 {
		branch = args[0]
	} else {
		branch = branchName(false, true, false)
	}

	gitChain(false, [][]string{
		[]string{"fetch", remote},
		[]string{"pull", remote, branch},
	})

	console.Complete()
}

// Reset resets all uncommitted changes
func Reset(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	gitChain(false, [][]string{
		[]string{"reset", "--hard"},
		[]string{"clean", "-f"},
	})

	console.Complete()
}

// Delete deletes one or more branch both locally and on a remote.
func Delete(cmd *cobra.Command, branches []string) {
	prepareWriteCommand(cmd)

	deleteBranches(cmd, branches)
	console.Complete()
}

// Cleanup deletes all non default branches.
func Cleanup(cmd *cobra.Command, args []string) {
	prepareWriteCommand(cmd)

	gitChain(false, [][]string{[]string{"fetch"}})
	result := git(true, "branch", "--merged")

	if !result.Success() { // The command failed
		console.Fatal("Cannot list GIT branches.")
	}

	var toDelete []string
	for _, branch := range strings.Split(strings.TrimSpace(result.Stdout), "\n") {
		branch = strings.TrimSpace(branch)

		if !(strings.HasPrefix(branch, "* ") || branch == "master" || branch == configuration.DefaultBranch) {
			toDelete = append(toDelete, branch)
		}
	}

	gitChain(false, [][]string{append([]string{"branch", "-D"}, toDelete...)})
	console.Complete()
}
