package main

import (
	"fmt"
	"strings"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
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
  all        Build everything listed below
  builder    Build builder
  initramfs  Build initramfs image
  multiboot  Build grub multiboot image
  iso        Build bootable ISO
  isofull    Build initramfs, multiboot and iso`
	examples := fmt.Sprintf("  # Full Build\n  %s\n\n", color.GreenL("sudo ./reduce -c build all personal"))
	examples += fmt.Sprintf("  # Full ISO Build\n  %s\n\n", color.GreenL("sudo ./reduce -c build isofull personal"))
	examples += fmt.Sprintf("  # Build a few different components\n  %s\n\n", color.GreenL("sudo ./reduce build multiboot,iso personal"))
	cmd := &cobra.Command{
		Use:   "build TARGETS PROFILE",
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
				reduce.CleanOpt(opts.clean),
				reduce.ProfileOpt(profile),
				reduce.DeploymentsOpt(opts.deployments),
			}
			return cli.Client.Build(targets, options...)
		},
	}
	cmd.Flags().BoolVarP(&opts.clean, "clean", "c", false, "Clean the components called out")
	cmd.Flags().StringSliceVarP(&opts.deployments, "deployments", "d", []string{}, "Deployments to specifically build")
	return cmd
}
