package abs

import (
	"fmt"

	"github.com/phR0ze/cyberlinux/cli/internal/arch/model"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/pkg/errors"
	"gopkg.in/src-d/go-billy.v4"
	"gopkg.in/src-d/go-billy.v4/memfs"
	"gopkg.in/src-d/go-git.v4"
	"gopkg.in/src-d/go-git.v4/plumbing"
	"gopkg.in/src-d/go-git.v4/storage/memory"
)

const (
	archGitRepoBaseURL = "https://git.archlinux.org/svntogit"
)

var (
	archGitRepos = []string{"packages", "community"}
)

// Interface provides a related set of ABS functions
type Interface interface {
	Info(pkg string) (model.Package, error) // Retrieves package details for the given packages
}

// ABS client
type ABS struct {
}

// New creates a new ABS client
func New(opts ...*opt.Opt) Interface {
	return &ABS{}
}

// Info for the given package
func (abs *ABS) Info(pkgname string) (pkg model.Package, err error) {
	branch := fmt.Sprintf("refs/heads/packages/%s", pkgname)
	url := fmt.Sprintf("%s/%s.git", archGitRepoBaseURL, archGitRepos[0])

	// Clone latest commit of a single branch into memory
	fs := memfs.New()
	if _, err = git.Clone(memory.NewStorage(), fs, &git.CloneOptions{
		URL: url, Depth: 1, Tags: git.NoTags,
		SingleBranch: true, ReferenceName: plumbing.ReferenceName(branch),
	}); err != nil {
		err = errors.Wrap(err, "Failed to clone abs repo")
		return
	}

	// Read the PKGBUILD file and convert it to a model.Package
	var file billy.File
	if file, err = fs.Open("trunk/PKGBUILD"); err != nil {
		err = errors.Wrap(err, "Failed to open the PKGBUILD file for reading")
		return
	}
	if pkg, err = model.ParsePkgBuild(file); err != nil {
		return
	}

	return
}
