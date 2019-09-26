package reduce

import "github.com/phR0ze/n/pkg/opt"

var (
	// CleanTargets that are supported
	CleanTargets = []string{
		"all",       // Clean everything listed below
		"builder",   // Clean builder
		"cache",     // Clean the package cache
		"initramfs", // Clean initramfs image
		"multiboot", // Clean grub multiboot image
		"iso",       // Clean bootable ISO
		"isofull",   // Clean initramfs, multiboot and iso
		"vms",       // Clean deployed vms
	}
)

// Clean reduce targets
func (reduce *Reduce) Clean(targets []string, opts ...*opt.Opt) (err error) {
	return
}
