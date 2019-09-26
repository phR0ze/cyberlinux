package main

import (
	"fmt"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/term/color"
	"github.com/spf13/cobra"
)

type buildOpts struct {
	clean       bool     // clean the build before building
	deployments []string // deployments to specifically build
}

func (cli *CLI) newBuildCmd() *cobra.Command {
	opts := &buildOpts{}
	title := "Build cyberlinux components"
	desc := `Supported Targets:
  all        Clean everything listed below
  builder    Clean builder
  cache      Clean the package cache
  initramfs  Clean initramfs image
  multiboot  Clean grub multiboot image
  iso        Clean bootable ISO
  isofull    Clean initramfs, multiboot and iso
  vms        Clean deployed vms`
	examples := fmt.Sprintf("  # Full ISO Build\n  %s\n\n", color.GreenL("sudo ./reduce -c build all personal"))
	cmd := &cobra.Command{
		Use:       "build TARGETS",
		Short:     title,
		Long:      fmt.Sprintf("%s\n\n%s\n\nExamples:\n%s", color.CyanBL(title), desc, examples),
		Args:      MinimumNArgs(1),
		ValidArgs: []string{"all", "builder", "initramfs", "multiboot", "iso", "isofull"},
		RunE: func(cmd *cobra.Command, targets []string) (err error) {
			if err = OnlyValidArgs(cmd, targets); err != nil {
				return
			}
			if err = cli.init(); err != nil {
				return
			}
			return cli.Client.Build(targets, reduce.CleanOpt(opts.clean), reduce.DeploymentsOpt(opts.deployments))
		},
	}
	cmd.Flags().BoolVarP(&opts.clean, "clean", "c", false, "Clean the components called out")
	cmd.Flags().StringSliceVarP(&opts.deployments, "deployments", "d", []string{}, "Deployments to specifically build")
	return cmd
}
