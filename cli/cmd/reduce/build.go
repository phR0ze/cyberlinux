package main

import (
	"fmt"

	"github.com/phR0ze/n/pkg/term/color"
	"github.com/spf13/cobra"
)

type buildOpts struct {
	clean bool // clean the build before building
}

func (cli *CLI) newBuildCmd() *cobra.Command {
	opts := &buildOpts{}
	title := "Build cyberlinux components"
	examples := fmt.Sprintf("  # Full ISO Build\n  %s\n\n", color.GreenL("sudo ./reduce -c build all personal"))
	cmd := &cobra.Command{
		Use:   "build",
		Short: title,
		Long:  fmt.Sprintf("%s\n\nExamples:\n%s", color.CyanBL(title), examples),

		RunE: func(cmd *cobra.Command, args []string) (err error) {
			return
		},
	}
	cmd.Flags().BoolVarP(&opts.clean, "clean", "c", false, "Clean the components called out")
	return cmd
}
