/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 */

package bookmarks

import (
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var defaultFilePath = filepath.Join(os.Getenv("HOME"), ".fishamnium_bookmarks.json")

func getBookmarksFilePath(cmd *cobra.Command) (filePath string) {
	filePath, _ = cmd.Flags().GetString("file")

	if filePath == "" {
		filePath = defaultFilePath
	}

	return
}

// InitCLI setups the bookmarks module
func InitCLI() *cobra.Command {
	parent := &cobra.Command{Use: "bookmarks", Short: "Manage bookmarks."}
	parent.PersistentFlags().StringP("file", "f", defaultFilePath, "Bookmarks file.")

	parent.AddCommand(&cobra.Command{
		Use: "read <name>", Aliases: []string{"get", "show", "load", "r", "g", "b"}, Short: "Reads a bookmark.", Args: cobra.MinimumNArgs(1), Run: ReadBookmark,
	})
	parent.AddCommand(&cobra.Command{
		Use: "write <name> [description]", Aliases: []string{"set", "save", "store", "w", "s"},
		Short: "Writes a bookmark.", Args: cobra.RangeArgs(1, 2), Run: WriteBookmark,
	})
	parent.AddCommand(&cobra.Command{
		Use: "delete <name>", Aliases: []string{"erase", "remove", "d", "e"}, Short: "Deletes a bookmark.", Args: cobra.MinimumNArgs(1), Run: DeleteBookmark,
	})

	var listSubcommand = &cobra.Command{
		Use: "list [query]", Aliases: []string{"all", "l", "a"}, Short: "Lists all bookmark.", Args: cobra.MaximumNArgs(1), Run: ListBookmarks,
	}
	listSubcommand.Flags().BoolP("names-only", "n", false, "Only list bookmarks names.")
	listSubcommand.Flags().BoolP("autocomplete", "a", false, "Only list bookmarks name and description for autocompletion.")
	parent.AddCommand(listSubcommand)

	parent.AddCommand(&cobra.Command{
		Use: "convert <source>", Short: "Converts a old bookmarks file to the new format.", Args: cobra.RangeArgs(0, 1), Run: ConvertBookmarks,
	})
	return parent
}
