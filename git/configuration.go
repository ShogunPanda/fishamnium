/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit/.
 */

package git

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"path"

	"github.com/ShogunPanda/fishamnium/console"
)

// Configuration represents the Fishamnium GIT configuration
type Configuration struct {
	DefaultBranch string `json:"defaultBranch"`
	DefaultRemote string `json:"defaultRemote"`
	DefaultPrefix string `json:"defaultPrefix"`
	OpenPath      string `json:"openPath"`
	PrependTask   bool   `json:"prependTask"`
	Quiet         bool   `json:"quiet"`
	Debug         bool   `json:"debug"`
	DryRun        bool   `json:"dryRun"`
}

func environmentOverrideConfiguration(configuration *Configuration) {
	if envValue, envSet := os.LookupEnv("GIT_DEFAULT_BRANCH"); envSet {
		configuration.DefaultBranch = envValue
	}
	if envValue, envSet := os.LookupEnv("GIT_DEFAULT_REMOTE"); envSet {
		configuration.DefaultRemote = envValue
	}
	if envValue, envSet := os.LookupEnv("GIT_DEFAULT_PREFIX"); envSet {
		configuration.DefaultPrefix = envValue
	}
	if envValue, envSet := os.LookupEnv("GIT_OPEN_PATH"); envSet {
		configuration.OpenPath = envValue
	}
	if envValue, envSet := os.LookupEnv("GIT_TASK_PREPEND"); envSet {
		configuration.PrependTask = envValue == "true"
	}
	if envValue, envSet := os.LookupEnv("QUIET"); envSet {
		configuration.Quiet = envValue == "true"
	}
	if envValue, envSet := os.LookupEnv("DEBUG"); envSet {
		configuration.Debug = envValue == "true"
	}
}

func loadConfiguration() (rv Configuration) {
	var configuration = defaultConfiguration

	// First of all, try to load the file starting from the current folder and traversing up to root - Then trying with the home folder
	visitedFolders := make(map[string]bool)
	var folders []string
	pwd, _ := os.Getwd()
	home := os.Getenv("HOME")

	for _, currentFolder := range []string{pwd, home} {
		for currentFolder != "" {
			if visitedFolders[currentFolder] {
				break
			}

			folders = append(folders, currentFolder)
			visitedFolders[currentFolder] = true

			// Go to the parent folder
			if currentFolder == "/" {
				currentFolder = ""
			} else {
				currentFolder = path.Dir(currentFolder)
			}
		}
	}

	// Check in which folder the file exists
	var configurationPath string
	for _, folder := range folders {
		tempPath := path.Join(folder, ".fishamnium_git.json")

		if _, err := os.Stat(tempPath); err == nil {
			configurationPath = tempPath
			break
		}
	}

	// Parse JSON, if any found
	if configurationPath != "" {
		rawConfiguration, err := ioutil.ReadFile(configurationPath)

		if err == nil {
			err = json.Unmarshal(rawConfiguration, &configuration)
		}

		if err != nil {
			console.Warn("The configuration file {yellow|bold}%s{-} is not a valid JSON file. Ignoring it.", configurationPath)
		}
	}

	// Merge with the environment
	environmentOverrideConfiguration(&configuration)

	return configuration
}

var defaultConfiguration = Configuration{
	DefaultBranch: "development", DefaultRemote: "origin", DefaultPrefix: "release-", OpenPath: "/usr/bin/open", PrependTask: false, Quiet: false, Debug: false,
}

var configuration = loadConfiguration()
