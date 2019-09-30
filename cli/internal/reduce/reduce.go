package reduce

import (
	"path"

	"github.com/phR0ze/cyberlinux/cli/internal/aur"
	"github.com/phR0ze/n"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/phR0ze/n/pkg/structs"
	"github.com/phR0ze/n/pkg/sys"
	"github.com/pkg/errors"
)

var (
	gKeys = structs.Init(&gKeysStruct{}).(*gKeysStruct)
)

// Reduce instance
type Reduce struct {
	opt.StdProps

	rootDir        string // path to cyberlinux
	outDir         string // path to rootDir/temp
	vagrantDir     string // path to rootDir/vagrant
	pacmanDir      string // path to outDir/pacman
	pacmanCacheDir string // path to pacmanDir/cache
	workDir        string // path to outDir/work
	tmpDir         string // path to workDir/tmp
	isoDir         string // path to workDir/_iso_

	aurClient aur.Interface // aur client to use
}

// Interface is the public interface for reduce
type Interface interface {
	Info() (Distro, error)                          // Info gets the target distro info
	Clean(targets []string, opts ...*opt.Opt) error // Clean reduce targets; opts: ProfileOpt
	Build(targets []string, opts ...*opt.Opt) error // Build reduce targets; opts: ProfileOpt, CleanOpt, DeploymentsOpt
}

// New reduce client supports opt.StdProps, Root and AurClient
func New(opts ...*opt.Opt) (ins Interface, err error) {
	reduce := &Reduce{}
	reduce.In = opt.GetInOpt(opts)
	reduce.Out = opt.GetOutOpt(opts)
	reduce.Err = opt.GetErrOpt(opts)
	reduce.Home = opt.GetHomeOpt(opts)
	reduce.Quiet = opt.GetQuietOpt(opts)
	reduce.Debug = opt.GetDebugOpt(opts)
	reduce.DryRun = opt.GetDryRunOpt(opts)
	reduce.Testing = opt.GetTestingOpt(opts)
	reduce.rootDir = GetRootOpt(opts)
	reduce.aurClient = DefaultAurClientOpt(opts, aur.New())

	// Determine paths
	if err = reduce.getRootDir(); err != nil {
		return
	}
	reduce.outDir = path.Join(reduce.rootDir, "temp")
	reduce.vagrantDir = path.Join(reduce.rootDir, "vagrant")
	reduce.pacmanDir = path.Join(reduce.outDir, "pacman")
	reduce.pacmanCacheDir = path.Join(reduce.pacmanDir, "cache")
	reduce.workDir = path.Join(reduce.outDir, "work")
	reduce.tmpDir = path.Join(reduce.workDir, "tmp")
	reduce.isoDir = path.Join(reduce.workDir, "_iso_")

	ins = reduce
	return
}

// Create the directory structure expected by reduce
func (reduce *Reduce) createDirs() (changed bool, err error) {
	if !sys.Exists(reduce.outDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.outDir); err != nil {
			return
		}
	}
	if !sys.Exists(reduce.vagrantDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.vagrantDir); err != nil {
			return
		}
	}
	if !sys.Exists(reduce.pacmanDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.pacmanDir); err != nil {
			return
		}
	}
	if !sys.Exists(reduce.pacmanCacheDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.pacmanCacheDir); err != nil {
			return
		}
	}
	if !sys.Exists(reduce.workDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.workDir); err != nil {
			return
		}
	}
	if !sys.Exists(reduce.tmpDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.tmpDir); err != nil {
			return
		}
	}
	if !sys.Exists(reduce.isoDir) {
		changed = true
		if _, err = sys.MkdirP(reduce.isoDir); err != nil {
			return
		}
	}
	return
}

// Get the root path for cyberlinux from the executable path
func (reduce *Reduce) getRootDir() (err error) {
	if reduce.rootDir != "" {
		return
	}

	// Find cyberlinux in the executable path
	if reduce.rootDir, err = sys.Executable(); err != nil {
		return
	}
	pieces := n.A(reduce.rootDir).Split("/")
	i := pieces.Index(gKeys.cyberlinux)

	// Find cyberlinux in the current working path
	if i == -1 {
		pieces = n.A(sys.Pwd()).Split("/")
		i = pieces.Index(gKeys.cyberlinux)
		if i == -1 {
			err = errors.Errorf("Failed to find cyberlinux root path")
			return
		}
	}

	reduce.rootDir = pieces.Slice(0, i).Join("/").A()
	return
}
