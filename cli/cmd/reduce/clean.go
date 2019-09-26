package main

import (
	"fmt"
	"strings"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/phR0ze/n/pkg/term/color"
	"github.com/spf13/cobra"
)

func (cli *CLI) newCleanCmd() *cobra.Command {
	title := "Clean cyberlinux components"
	desc := `Supported Targets:
  all        Clean everything listed below
  builder    Clean builder
  cache      Clean the package cache
  initramfs  Clean initramfs image
  multiboot  Clean grub multiboot image
  iso        Clean bootable ISO
  isofull    Clean initramfs, multiboot and iso
  vms        Clean deployed vms`
	examples := fmt.Sprintf("  # Clean everything\n  %s\n\n", color.GreenL("sudo ./reduce clean all personal"))
	examples += fmt.Sprintf("  # Clean for a full rebuild\n  %s\n\n", color.GreenL("sudo ./reduce clean isofull personal"))
	examples += fmt.Sprintf("  # Clean a few different components\n  %s\n\n", color.GreenL("sudo ./reduce clean cache,builder,iso personal"))
	cmd := &cobra.Command{
		Use:   "clean TARGETS PROFILE",
		Short: title,
		Long:  fmt.Sprintf("%s\n\n%s\n\nExamples:\n%s", color.CyanBL(title), desc, examples),
		Args:  ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) (err error) {

			// Get arguments
			targets := strings.Split(args[0], ",")
			profile := args[1]

			// Initialize
			if err = cli.init(); err != nil {
				return
			}

			// Call client
			options := []*opt.Opt{
				reduce.ProfileOpt(profile),
			}
			return cli.Client.Clean(targets, options...)
		},
	}
	return cmd
}
