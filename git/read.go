/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 */

package git

import (
	"encoding/json"
	"fmt"
	"regexp"
	"strings"

	"github.com/spf13/cobra"

	"github.com/ShogunPanda/fishamnium/console"
)

var regexpMEmulator, _ = regexp.Compile("\\s+")
var taskMatcher, _ = regexp.Compile(regexpMEmulator.ReplaceAllString(`(?i)
  ^(?:
		(?:((?:[a-z#]+-)?\d+)-{1,2})?
		(?:.+?)
		(?:-{1,2}((?:[a-z#]+-)?\d+))?
  )$
`, ""))

func isRepository(fatal, standalone bool) bool {
	// Execute the command
	result := git(true, "rev-parse", "--is-inside-work-tree").Success()

	if standalone { // Direct call, just print the result
		fmt.Println(result)
	} else if fatal && !result { // The command failed, assume we're not in a GIT Repository
		console.Fatal("You're not inside a git repository.")
	}

	return result // Assume we are a in GIT repository if the command succeded
}

func isDirty(fatal, standalone bool) bool {
	// Check we are in a GIT Repository
	isRepository(fatal, false)

	// Execute the command
	result := git(true, "status", "-s")

	// Parse output
	dirty := result.Success() && len(result.Stdout) > 0

	if standalone { // Direct call, just print the result
		fmt.Println(dirty)
	} else if fatal && !result.Success() { // The command failed
		console.Fatal("Cannot check GIT status.")
	}

	return dirty
}

func branchName(full, fatal, standalone bool) string {
	// Execute some commands to get the reference
	result := git(true, "symbolic-ref", "HEAD")

	if !result.Success() {
		result = git(true, "rev-parse", "--short", "HEAD")
	}

	name := strings.TrimSpace(string(result.Stdout))

	if fatal && !result.Success() { // The command failed
		console.Fatal("Cannot check GIT branch name.")
	}

	if !full {
		name = strings.Replace(name, "refs/heads/", "", 1)
	}

	return handleReadOutput(name, standalone)
}

func sha(full, fatal, standalone bool) string {
	// Setup arguments
	args := []string{"rev-parse", "--short", "HEAD"}

	if full {
		args = append(args[:1], args[2])
	}

	// Execute the command
	result := git(true, args...)

	if fatal && !result.Success() { // The command failed
		console.Fatal("Cannot check GIT SHA.")
	}

	return handleReadOutput(strings.TrimSpace(string(result.Stdout)), standalone)
}

func task(fatal, standalone bool) string {
	// Get the branch name
	name := branchName(false, true, false)

	// Apply the matcher on the last part of the branch name
	nameTokens := strings.Split(name, "/")
	match := taskMatcher.FindStringSubmatch(nameTokens[len(nameTokens)-1])

	task := ""
	if len(match) == 3 && match[1] == "" && match[2] != "" {
		task = match[2]
	} else if len(match) > 1 && match[1] != "" {
		task = match[1]
	}

	return handleReadOutput(task, standalone)
}

// IsRepository checks if the current working directory is a GIT repository
func IsRepository(cmd *cobra.Command, args []string) {
	isRepository(true, true)
}

// IsDirty checks if the current GIT Repository contains uncommited changes
func IsDirty(cmd *cobra.Command, args []string) {
	isDirty(true, true)
}

// ShowRemotes lists all the remotes for the current GIT Repository
func ShowRemotes(cmd *cobra.Command, args []string) {
	// Check we are in a GIT Repository
	isRepository(true, false)

	// Execute the command
	result := git(true, "remote", "-v")

	if !result.Success() { // The command failed
		console.Fatal("Cannot list GIT remotes.")
	}

	// Parse the output and group in map indexed by remote name
	splitter, _ := regexp.Compile("\\s+")
	remotes := map[string]Remote{}
	for _, entry := range strings.Split(strings.TrimSpace(string(result.Stdout)), "\n") {
		s := splitter.Split(entry, -1)
		name, url, which := s[0], s[1], s[2]

		remote := Remote{Fetch: url, Push: url} // Create a new remote
		remote = remotes[name]                  // Check if it is in the map
		remote.Update(which, url)               // Updated it
		remotes[name] = remote
	}

	if autocomplete, _ := cmd.Flags().GetBool("autocomplete"); autocomplete {
		// Format for autocompletion
		for name, remote := range remotes {
			fmt.Printf("%s\tGIT Remote: %s\n", name, remote.Fetch)
		}
	} else {
		rawRemotes, _ := json.MarshalIndent(&remotes, "", "  ")
		fmt.Println(string(rawRemotes))
	}
}

// FullBranchName shows the full current branch name
func FullBranchName(cmd *cobra.Command, args []string) {
	isRepository(true, false)
	branchName(true, true, true)
}

// BranchName shows the full current branch name
func BranchName(cmd *cobra.Command, args []string) {
	isRepository(true, false)
	branchName(false, true, true)
}

// FullSha shows the full current branch sha
func FullSha(cmd *cobra.Command, args []string) {
	isRepository(true, false)
	sha(true, true, true)
}

// Sha shows the full current branch sha
func Sha(cmd *cobra.Command, args []string) {
	isRepository(true, false)
	sha(false, true, true)
}

// Task shows the current task
func Task(cmd *cobra.Command, args []string) {
	isRepository(true, false)
	task(true, true)
}

// Summary shows the current branch name, the current SHA and whether the working directory is dirty
func Summary(cmd *cobra.Command, args []string) {
	if !isRepository(false, false) {
		return
	}

	// Prepare structures
	var name, shaHash string
	var dirty bool
	nameChan := make(chan string)
	shaChan := make(chan string)
	dirtyChan := make(chan bool)

	// Execute commands in parallel
	go func() { nameChan <- branchName(false, true, false) }()
	go func() { shaChan <- sha(false, true, false) }()
	go func() { dirtyChan <- isDirty(false, false) }()

	// Get information
	for i := 0; i < 3; i++ {
		select {
		case name = <-nameChan:
		case shaHash = <-shaChan:
		case dirty = <-dirtyChan:
		}
	}

	// Print result
	fmt.Printf("%s %s %v\n", name, shaHash, dirty)
}