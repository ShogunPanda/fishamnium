/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
 */

package bookmarks

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"sort"
	"strings"

	"github.com/ShogunPanda/fishamnium/console"
	"github.com/spf13/cobra"
)

// Bookmark represent a saved bookmark
type Bookmark struct {
	Name     string   `json:"name"`
	Bookmark string   `json:"bookmark"`
	RootPath string   `json:"rootPath"`
	Paths    []string `json:"paths"`
	Group    string   `json:"group"`
}

var bookmarkValidator, _ = regexp.Compile("(?i)(?:^(?:[a-z0-9-_.:@]+)$)")
var rootFormatter, _ = regexp.Compile(fmt.Sprintf("^(?:%s)", regexp.QuoteMeta(os.Getenv("HOME"))))

func nameToRichName(name string) string {
	return strings.Title(strings.Replace(strings.Replace(name, "-", " ", -1), "_", " ", -1))
}

func replaceDestination(destination string) string {
	return rootFormatter.ReplaceAllString(destination, "$$home")
}

func resolveDestination(bookmark Bookmark) string {
	return strings.Replace(bookmark.RootPath, "$home", os.Getenv("HOME"), 1)
}

func humanizeDestination(bookmark Bookmark) string {
	return strings.Replace(resolveDestination(bookmark), os.Getenv("HOME"), console.Colorize("{yellow}$HOME{-}"), 1)
}

func loadBookmarks(filePath string) (bookmarks map[string]Bookmark) {
	bookmarksList := make([]Bookmark, 0)
	var rawBookmarksList []byte

	// Read the file
	rawBookmarksList, err := ioutil.ReadFile(filePath)
	if err != nil {
		console.Fatal("Cannot load file %s", filePath)
		return
	}

	// Parse JSON
	if err = json.Unmarshal(rawBookmarksList, &bookmarksList); err != nil {
		console.Fatal("Cannot parse JSON file %s", filePath)
		return
	}

	// Convert the list to an array
	bookmarks = make(map[string]Bookmark)

	for _, b := range bookmarksList {
		bookmarks[b.Bookmark] = b
	}

	return
}

func storeBookmarks(filePath string, bookmarks map[string]Bookmark) {
	// Convert back to a list
	var list []Bookmark
	var keys []string
	for k := range bookmarks {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	for _, k := range keys {
		list = append(list, bookmarks[k])
	}

	// Serialize and write file
	serialized, _ := json.MarshalIndent(list, "", "  ")

	if err := ioutil.WriteFile(filePath, []byte(serialized), 0755); err != nil {
		console.Fatal("Cannot save file %s.", filePath)
	}
}

// ReadBookmark shows a bookmark
func ReadBookmark(cmd *cobra.Command, args []string) {
	bookmarks := loadBookmarks(getBookmarksFilePath(cmd))
	bookmark, present := bookmarks[args[0]]

	if !present {
		console.Fatal("The bookmark {yellow|bold}%s{-} does not exists.", args[0])
		return
	}

	fmt.Println(resolveDestination(bookmark))
}

// WriteBookmark saves a bookmark
func WriteBookmark(cmd *cobra.Command, args []string) {
	bookmarksFilePath := getBookmarksFilePath(cmd)
	bookmarks := loadBookmarks(bookmarksFilePath)

	bookmarkName := args[0]
	bookmark, present := bookmarks[bookmarkName]

	if present {
		console.Fatal("The bookmark {white}%s{-} already exists and points to {white}%s{-}.", bookmarkName, humanizeDestination(bookmark))
		return
	} else if !bookmarkValidator.MatchString(bookmarkName) {
		console.Fatal(`Use only {white}letters{-}, {white}numbers{-}, and {white}-{-}, {white}_{-}, {white}.{-}, {white}:{-} and {white}@{-} for the bookmark name.`)
		return
	}

	// Parse the name
	name := ""
	if len(args) > 1 {
		name = args[1]
	} else {
		name = nameToRichName(bookmarkName)
	}

	// Format destination
	pwd, _ := os.Getwd()

	bookmarks[bookmarkName] = Bookmark{Name: name, Bookmark: bookmarkName, RootPath: replaceDestination(pwd), Paths: make([]string, 0), Group: ""}
	storeBookmarks(bookmarksFilePath, bookmarks)
}

// DeleteBookmark deletes a bookmark
func DeleteBookmark(cmd *cobra.Command, args []string) {
	bookmarksFilePath := getBookmarksFilePath(cmd)
	bookmarks := loadBookmarks(bookmarksFilePath)
	_, present := bookmarks[args[0]]

	if !present {
		console.Fatal("The bookmark {white}%s{-} does not exists.", args[0])
		return
	}

	delete(bookmarks, args[0])
	storeBookmarks(bookmarksFilePath, bookmarks)
}

// ListBookmarks lists all bookmarks
func ListBookmarks(cmd *cobra.Command, args []string) {
	bookmarks := loadBookmarks(getBookmarksFilePath(cmd))

	// Parse arguments
	maxLength := 0
	namesOnly, _ := cmd.Flags().GetBool("names-only")
	autocomplete, _ := cmd.Flags().GetBool("autocomplete")
	var query string

	if len(args) > 0 {
		query = args[0]
	}

	// Sort bookmarks by name
	var keys []string
	for k := range bookmarks {
		if query != "" && !strings.Contains(k, query) {
			continue
		}

		keys = append(keys, k)

		if len(k) > maxLength { // Track the maximum name length for pretty printing
			maxLength = len(k)
		}
	}
	sort.Sort(sort.StringSlice(keys))

	// Check if we just want names
	if namesOnly {
		fmt.Printf(strings.Join(keys, "\n"))
		return
	}

	// Print bookmarks, either in human or autocomplete mode
	for _, k := range keys {
		bookmark := bookmarks[k]

		if autocomplete {
			fmt.Printf("%s\t%s\n", bookmark.Bookmark, bookmark.Name)
		} else {
			fmt.Printf(console.Colorize(fmt.Sprintf("{green}%%-%ds{-} \u2192 {yellow}%%s{-}\n", maxLength)), bookmark.Bookmark, humanizeDestination(bookmark))
		}
	}
}

// ConvertBookmarks converts a old bookmarks file to a new one .
func ConvertBookmarks(cmd *cobra.Command, args []string) {
	// Parse arguments
	destination := getBookmarksFilePath(cmd)
	source := destination

	if len(args) > 0 {
		source = args[0]
	}

	// Read the file
	rawOldBookmarks, err := ioutil.ReadFile(source)
	if err != nil {
		console.Fatal("Cannot load source file %s", source)
		return
	}

	// Parse JSON
	var oldBookmarks map[string]string
	if err = json.Unmarshal(rawOldBookmarks, &oldBookmarks); err != nil {
		console.Fatal("Cannot parse source JSON file %s", source)
		return
	}

	// Create the new bookmarks
	bookmarks := map[string]Bookmark{}
	for name, path := range oldBookmarks {
		bookmarks[name] = Bookmark{Name: name, Bookmark: nameToRichName(name), RootPath: replaceDestination(path), Paths: make([]string, 0), Group: ""}
	}

	fmt.Println(oldBookmarks)
	fmt.Println(bookmarks)

	storeBookmarks(destination, bookmarks)
}
