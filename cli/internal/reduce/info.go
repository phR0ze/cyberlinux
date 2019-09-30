package reduce

import (
	"github.com/phR0ze/cyberlinux/cli/internal/aur"
)

// Distro provides information about the distro being built
type Distro struct {
	Name      string // Distro name
	Release   string // target release
	Arch      string // target architecture e.g. x86_64
	Kernel    string // target kernel string e.g.
	KernelVer string // target kernel version e.g. 5.3.1
}

// Info about the target distro
func (reduce *Reduce) Info() (distro Distro, err error) {
	aur.New()
}
