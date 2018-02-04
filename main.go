/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package main

import (
	"fmt"
	"strings"

	"github.com/spf13/cobra"

	"github.com/ShogunPanda/fishamnium/bookmarks"
	"github.com/ShogunPanda/fishamnium/git"
)

func autocomplete(root *cobra.Command) {
	for _, cmd := range root.Commands() {
		if cmd.Use == "autocomplete" {
			continue
		}

		description := cmd.Short

		for _, alias := range append([]string{strings.Split(cmd.Use, " ")[0]}, cmd.Aliases...) {
			fmt.Printf("%s\t%s\n", alias, description)
		}
	}
}

func main() {
	var rootCmd = &cobra.Command{Use: "fishamnium", Short: "Fishamnium shell helper"}
	var bookmarksCmd = bookmarks.InitCLI()
	var gitCmd = git.InitCLI()

	bookmarksCmd.AddCommand(&cobra.Command{
		Use: "autocomplete", Short: "Show autocompletions for commands.", Run: func(cmd *cobra.Command, args []string) { autocomplete(bookmarksCmd) },
	})

	gitCmd.AddCommand(&cobra.Command{
		Use: "autocomplete", Short: "Show autocompletions for commands.", Run: func(cmd *cobra.Command, args []string) { autocomplete(gitCmd) },
	})

	rootCmd.AddCommand(bookmarksCmd)
	rootCmd.AddCommand(gitCmd)

	rootCmd.Execute()
}
