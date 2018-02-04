/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package git

import (
	"bufio"
	"fmt"
	"net/url"
	"regexp"
	"strings"
)

// Remote represent a GIT Remote
type Remote struct {
	Fetch string
	Push  string
}

var remoteTypeGithubMatcher, _ = regexp.Compile("(?i)^(?:To github\\.com:)(.+)(?:\\.git)$")
var remoteTypeGitlabMatcher, _ = regexp.Compile("(?i)^(?:To gitlab\\.com:)(.+)(?:\\.git)$")
var remoteTypeBitbucketMatcher, _ = regexp.Compile("(?i)^(?:remote:\\s+)(.+compare/commits)(\\?sourceBranch.+)$")

// Update updates the field of a Remote
func (t *Remote) Update(field, value string) {
	replacer, _ := regexp.Compile("[\\(\\)]")

	switch replacer.ReplaceAllString(field, "") {
	case "fetch":
		t.Fetch = value
	case "push":
		t.Push = value
	}
}

// MarshalJSON serializes a Remote as JSON
func (t Remote) MarshalJSON() (out []byte, err error) {
	if t.Fetch == t.Push {
		out = []byte(fmt.Sprintf("\"%s\"", t.Fetch))
	} else {
		out = []byte(fmt.Sprintf("{\"fetch\":\"%s\", \"push\":\"%s\"}", t.Fetch, t.Push))
	}

	return
}

func buildPRURL(output, base, branch string) string {
	scanner := bufio.NewScanner(strings.NewReader(output))
	var prURL string

URLScanning:
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		var match []string
		if match = remoteTypeGithubMatcher.FindStringSubmatch(line); len(match) > 1 { // GitHub
			tempURL, _ := url.Parse("https://github.com/")
			tempURL.Path = fmt.Sprintf("%s/compare/%s...%s", match[1], base, branch)
			query := tempURL.Query()
			query.Set("expand", "1")
			tempURL.RawQuery = query.Encode()

			prURL = tempURL.String()
			break URLScanning
		} else if match = remoteTypeGitlabMatcher.FindStringSubmatch(line); len(match) > 1 { // Gitlab
			tempURL, _ := url.Parse("https://gitlab.com/")
			tempURL.Path = fmt.Sprintf("%s/merge_requests/new", match[1])
			query := tempURL.Query()
			query.Set("merge_request[source_branch]", branch)
			query.Set("merge_request[target_branch]", base)
			tempURL.RawQuery = query.Encode()

			prURL = tempURL.String()
		} else if match = remoteTypeBitbucketMatcher.FindStringSubmatch(line); len(match) > 1 { // BitBucket
			tempURL, _ := url.Parse(match[1])
			query := tempURL.Query()
			query.Set("sourceBranch", branch)
			query.Set("targetBranch", base)
			tempURL.RawQuery = query.Encode()

			prURL = tempURL.String()
		}
	}

	// Now find the PR url
	return prURL
}
