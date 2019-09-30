// Package smac provides some helper functions for interacting with arch packages
package smac

import (
	git "github.com/src-d/go-git"
)

const (
	archGitRepoBaseURL = "https://git.archlinux.org/svntogit"
)

var (
	archGitRepos = []string{"packages", "community"}
)

// DownloadABS source files for the given package
func DownloadABS(pkg string) (err error) {

	r, err := git.Clone(memory.NewStorage(), nil, &git.CloneOptions{
		URL: "https://github.com/src-d/go-siva",
	})

	return
}
