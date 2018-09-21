/*
 * This file is part of fishamnium. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
 * Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
 */

package git

import (
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

var remoteTypeGithubMatcher, _ = regexp.Compile("(?i)^.+github\\.com[:/](.+)\\.git$")
var remoteTypeGitlabMatcher, _ = regexp.Compile("(?i)^.+gitlab\\.com[:/](.+)\\.git$")
var remoteTypeBitbucketMatcher, _ = regexp.Compile("(?i)^.+:7999/(?:scm/?)(.+)\\.git$")

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

func buildPRURL(base, branch, remote string) string {
	var prURL string

	// Get the full URL for the remote
	remoteURL := strings.TrimSpace(git(true, "remote", "get-url", remote).Stdout)
	parsedRemoteURL, _ := url.Parse(remoteURL)

	// Check the provider
	if strings.HasPrefix(remoteURL, "https://github.com") || strings.HasPrefix(remoteURL, "git@github.com") { // GitHub
		repo := remoteTypeGithubMatcher.FindStringSubmatch(remoteURL)[1]
		prURL = fmt.Sprintf("https://github.com/%s/compare/%s...%s?expand=1", repo, base, branch)
	} else if strings.HasPrefix(remoteURL, "https://gitlab.com") || strings.HasPrefix(remoteURL, "git@gitlab.com") { // Gitlab
		repo := remoteTypeGitlabMatcher.FindStringSubmatch(remoteURL)[1]
		prURL = fmt.Sprintf(
			"https://gitlab.com/%s/merge_requests/new?merge_request%%5Btarget_branch%%5D=%s&merge_request%%5Bsource_branch%%5D=%s",
			repo, base, branch,
		)
	} else if (strings.HasPrefix(parsedRemoteURL.Scheme, "http") && parsedRemoteURL.Port() == "7990") ||
		(strings.HasPrefix(parsedRemoteURL.Scheme, "ssh") && parsedRemoteURL.Port() == "7999") { // Hosted bitbucket

		repo := strings.Split(strings.TrimPrefix(strings.TrimPrefix(strings.TrimSuffix(parsedRemoteURL.Path, ".git"), "/scm/"), "/"), "/")

		prURL = fmt.Sprintf(
			"http://%s:7990/projects/%s/repos/%s/compare/commits?targetBranch=refs%%2Fheads%%2F%s&sourceBranch=refs%%2Fheads%%2F%s",
			parsedRemoteURL.Hostname(), repo[0], repo[1], base, branch,
		)
	}

	return prURL
}
