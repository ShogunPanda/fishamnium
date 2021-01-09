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

var platforms = [][]string{
	{"darwin", "amd64"}, 
	{"windows", "amd64"}, 
	{"linux", "amd64"}, 
	{"linux", "arm"}, 
	{"linux", "arm64"},
}

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
	for _, platform := range platforms {
		os := platform[0]
		arch := platform[1]

		executable := fmt.Sprintf("%s/dist/helpers/fishamnium-%s-%s", cwd, os, arch)
		err = execute(map[string]string{"GOARCH": arch, "GOOS": os, "GOARM": "7"}, "go", "build", "-o", executable, "-ldflags=-s -w")

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
