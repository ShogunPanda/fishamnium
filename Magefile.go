// +build mage

/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/magefile/mage/sh"
)

var cwd, _ = os.Getwd()
var arch = "amd64"
var oses = []string{"darwin", "linux", "windows"}
var versionMatcher = regexp.MustCompile("^(v(?:-?))")

func step(message string, args ...interface{}) {
	fmt.Printf("\x1b[33m--- %s\x1b[0m\n", fmt.Sprintf(message, args...))
}

func execute(env map[string]string, args ...string) error {
	step("Executing: %s ...", strings.Join(args, " "))

	_, err := sh.Exec(env, os.Stdout, os.Stderr, args[0], args[1:]...)

	return err
}

// Build the helper and prepare the dist folder.
func Build() error {
	err := Clean()

	if err != nil {
		return err
	}

	distFolder := filepath.Join(cwd, "dist")

	// Copy shell files
	err = execute(nil, "cp", "-a", filepath.Join(cwd, "shell"), distFolder)

	if err != nil {
		return err
	}

	// Compile executables
	for _, os := range oses {
		executable := fmt.Sprintf("%s/dist/helpers/fishamnium-%s", cwd, os)
		err = execute(map[string]string{"GOARCH": arch, "GOOS": os}, "go", "build", "-o", executable, "-ldflags=-s -w")

		if err != nil {
			return err
		}
	}

	return nil
}

// Cleans the build directories.
func Clean() error {
	step("Removing dist folder ...")
	return os.RemoveAll(filepath.Join(cwd, "dist"))
}

// Verifies the code.
func Lint() error {
	return execute(nil, "go", "vet")
}

var Default = Build
