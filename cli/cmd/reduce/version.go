package main

import (
	"fmt"
	"io"
	"os"

	"github.com/phR0ze/n/pkg/term/color"
	"github.com/spf13/cobra"
)

func (cli *CLI) newVersionCmd() *cobra.Command {
	title := "Show version information"
	examples := fmt.Sprintf("  # Check current versions\n  %s\n\n", color.GreenL("./reduce ver"))
	cmd := &cobra.Command{
		Use:     "version",
		Short:   title,
		Long:    fmt.Sprintf("%s\n\nExamples:\n%s", color.CyanBL(title), examples),
		Aliases: []string{"v", "ver"},
		RunE: func(cmd *cobra.Command, args []string) (err error) {
			cli.listVersions(os.Stdout)
			return
		},
	}
	return cmd
}

// Get the version
func (cli *CLI) listVersions(out io.Writer) {
	fmt.Fprintf(out, `Reduce
-------------------------------------------------------------
Version:           %s
Build Date:        %s
GitCommit:         %s
`, VERSION, BUILDDATE, GITCOMMIT)
}
