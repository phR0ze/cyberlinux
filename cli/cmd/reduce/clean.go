package main

import (
	"fmt"

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
	examples := fmt.Sprintf("  # Clean everything\n  %s\n\n", color.GreenL("sudo ./reduce clean all"))
	examples += fmt.Sprintf("  # Clean for a full rebuild\n  %s\n\n", color.GreenL("sudo ./reduce clean isofull"))
	examples += fmt.Sprintf("  # Clean a few different components\n  %s\n\n", color.GreenL("sudo ./reduce clean cache builder iso"))
	cmd := &cobra.Command{
		Use:       "clean TARGETS",
		Short:     title,
		Long:      fmt.Sprintf("%s\n\n%s\n\nExamples:\n%s", color.CyanBL(title), desc, examples),
		Args:      MinimumNArgs(1),
		ValidArgs: []string{"all", "builder", "cache", "initramfs", "multiboot", "iso", "isofull", "vms"},
		RunE: func(cmd *cobra.Command, targets []string) (err error) {
			if err = OnlyValidArgs(cmd, targets); err != nil {
				return
			}
			if err = cli.init(); err != nil {
				return
			}
			return cli.Client.Clean(targets)
		},
	}
	return cmd
}
