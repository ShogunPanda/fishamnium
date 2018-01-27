/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 */

package git

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
	"syscall"

	"github.com/ShogunPanda/fishamnium/console"
)

// ExecutionResult represents a command execution result
type ExecutionResult struct {
	ExitCode int
	Stdout   string
	Stderr   string
	Error    error
}

// Success checks whether the command was executed and exited with status 0
func (t ExecutionResult) Success() bool {
	return t.Error == nil && t.ExitCode == 0
}

func handleReadOutput(output string, standalone bool) string {
	if standalone {
		fmt.Println(output)
	}

	return output
}

func showAndBufferOutput(source io.ReadCloser, buffer *string, destination *os.File) {
	defer source.Close()

	scanner := bufio.NewScanner(source)

	for scanner.Scan() {
		line := scanner.Text()

		if destination != nil {
			fmt.Fprintln(destination, console.WrapOutput(line))
		}

		*buffer += line + "\n"
	}
}

func git(readOnly bool, args ...string) (result ExecutionResult) {
	gitCmd := exec.Command("git", args...)
	showOutput := !readOnly && !configuration.Quiet

	// Debugging messages
	if !readOnly && !configuration.Quiet {
		verb := "Executing"

		if configuration.DryRun {
			verb = "Will execute"
		}
		console.Debug("{yellow}%s: {bold}git %s", verb, strings.Join(args, " "))

	}

	// Nothing else to do
	if configuration.DryRun && !readOnly {
		return
	}

	// Pipe stdout and stderr
	var destinationOut, destinationErr *os.File

	if showOutput {
		destinationOut = os.Stdout
		destinationErr = os.Stderr
	}

	commandStdout, _ := gitCmd.StdoutPipe()
	commandStderr, _ := gitCmd.StderrPipe()
	go showAndBufferOutput(commandStdout, &result.Stdout, destinationOut)
	go showAndBufferOutput(commandStderr, &result.Stderr, destinationErr)

	// Execute the command
	result.Error = gitCmd.Run()

	// The command exited with errors, copy the exit code
	if result.Error != nil {
		if exitError, casted := result.Error.(*exec.ExitError); casted {
			result.Error = nil // Reset the error since it just a command failure
			result.ExitCode = exitError.Sys().(syscall.WaitStatus).ExitStatus()
		}
	}

	if showOutput {
		console.FinishStep(result.ExitCode)
	}

	return
}

func gitChain(readOnly bool, chain [][]string) (results []ExecutionResult) {
	for _, args := range chain {
		result := git(readOnly, args...)

		if result.Error != nil {
			console.Fatal("One of operations could not be executed: {bold}%s{-}.", result.Error.Error())
		} else if result.ExitCode != 0 {
			console.Fatal("One of operations failed with code {bold}%d{-}.", result.ExitCode)
		}

		results = append(results, result)
	}

	return
}
