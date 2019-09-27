package reduce

import (
	"fmt"

	"github.com/phR0ze/n"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/pkg/errors"
)

var (
	gBuildTargets = []string{
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
	clean, profile, deployments, iso, isofull, initramfs, multiboot, all, err := processBuildParams(targets, opts...)
	if err != nil {
		return
	}

	changed := false

	fmt.Println(changed)
	fmt.Println(clean)
	fmt.Println(profile)
	fmt.Println(deployments)
	fmt.Println(iso)
	fmt.Println(isofull)
	fmt.Println(initramfs)
	fmt.Println(multiboot)
	fmt.Println(all)
	return
}

// validate the build params
func processBuildParams(targets []string, opts ...*opt.Opt) (
	clean bool, profile string, deployments *n.StringSlice, iso, isofull, initramfs, multiboot, all bool, err error,
) {
	clean = GetCleanOpt(opts)
	profile = GetProfileOpt(opts)
	deployments = n.S(GetDeploymentsOpt(opts))

	if profile == "" {
		err = errors.Errorf("Profile not specified")
		return
	}
	if !n.S(gBuildTargets).AllS(targets) {
		err = errors.Errorf("Invalid targets given")
		return
	}

	iso = n.S(targets).Any(gKeys.iso)
	isofull = n.S(targets).Any(gKeys.isofull)
	initramfs = n.S(targets).Any(gKeys.initramfs)
	multiboot = n.S(targets).Any(gKeys.multiboot)
	all = n.S(targets).Any(gKeys.all)

	// Add builder to the deployments if builder is a target
	if n.S(targets).Any(gKeys.builder) && !deployments.Any(gKeys.builder) {
		deployments.Prepend(gKeys.builder)
	}

	return
}
