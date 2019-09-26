package reduce

import (
	"github.com/phR0ze/n/pkg/opt"
)

var (
	// BuildTargets that are supported
	BuildTargets = []string{
		"all",       // Build everything listed below
		"builder",   // Build builder
		"initramfs", // Build initramfs image
		"multiboot", // Build grub multiboot image
		"iso",       // Build bootable ISO
		"isofull",   // Build initramfs, multiboot and iso
	}
)

// Build reduce targets
func (reduce *Reduce) Build(targets []string, opts ...*opt.Opt) (err error) {

	return
}
