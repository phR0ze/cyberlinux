package main

import (
	"fmt"
	"os"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/phR0ze/n/pkg/term/color"
	"github.com/spf13/cobra"
)

var (
	VERSION   string
	BUILDDATE string
	GITCOMMIT string
)

// CLI instance
type CLI struct {
	opt.StdProps                  // standard options
	header       string           // boiler plate to print before all commands
	cmd          *cobra.Command   // root cobra command
	opts         []*opt.Opt       // options used at startup
	Client       reduce.Interface // Reduce client interface
}

// main entry point
func main() {
	c := New()
	if err := c.Execute(); err != nil {
		if argsErr, ok := err.(ArgsError); ok {
			argsErr.Command.Help()
			fmt.Println()
			c.LogError("Argument failure: the '%s' command's arguments were not satisfied", argsErr.Command.Name())
		} else {
			c.LogFatal(err)
		}
	}
}

// New initializes the CLI with the given options
func New(opts ...*opt.Opt) (cli *CLI) {
	cli = &CLI{}
	cli.In = opt.GetInOpt(opts)
	cli.Out = opt.GetOutOpt(opts)
	cli.Err = opt.GetErrOpt(opts)
	cli.Home = opt.GetHomeOpt(opts)
	cli.Quiet = opt.GetQuietOpt(opts)
	cli.Debug = opt.GetDebugOpt(opts)
	cli.DryRun = opt.GetDryRunOpt(opts)
	cli.Testing = opt.GetTestingOpt(opts)
	cli.Client = GetClientOpt(opts)
	n.SetOnEmpty(&VERSION, "999.999.999")
	cli.header = color.CyanBLU(fmt.Sprintf("Reduce v%s (%s)[%s]", VERSION, BUILDDATE, GITCOMMIT))

	// Configure Cobra commands
	//----------------------------------------------------------------------------------------------
	examples := fmt.Sprintf("  # Full ISO Build\n  %s\n\n", color.GreenL("sudo ./reduce -c build all personal"))
	examples += fmt.Sprintf("  # Single Deployment\n  %s\n\n", color.GreenL("sudo ./reduce -c build isofull personal -d lite"))
	examples += fmt.Sprintf("  # Rebuild initramfs\n  %s\n\n", color.GreenL("sudo ./reduce -c build initramfs,iso personal"))
	examples += fmt.Sprintf("  # Rebuild multiboot\n  %s\n\n", color.GreenL("sudo ./reduce -c build multiboot,iso personal"))

	desc := "cyberlinux build and deployment automation."
	cli.cmd = &cobra.Command{
		Use:  "reduce",
		Long: fmt.Sprintf("%s\n%s\n\nExamples:\n%s", cli.header, desc, examples),
		RunE: func(cmd *cobra.Command, args []string) error {
			return cmd.Help()
		},

		// Turns off RunE triggering help on errors, help is still
		// printed out for normal case, like missing params or -h
		SilenceUsage: true,

		// Silence cobra printing out the error as we'll handle it with logrus
		SilenceErrors: true,
	}

	cli.cmd.AddCommand(
		cli.newBuildCmd(),
		cli.newCleanCmd(),
		cli.newVersionCmd(),
	)

	// --debug
	cli.cmd.PersistentFlags().BoolVar(&cli.Debug, "debug", false, "Print out debug info")

	// --dry-run
	cli.cmd.PersistentFlags().BoolVar(&cli.DryRun, "dry-run", false, "Make no changes")

	// -q --quiet
	cli.cmd.PersistentFlags().BoolVarP(&cli.Quiet, "quiet", "q", false, "Use Error level logging and don't emit extraneous output")

	// Setup logging after we've read in the env variables
	cli.setupLogging()

	return
}

// Execute the CLI
func (cli *CLI) Execute(args ...string) (err error) {
	if len(args) > 0 {
		os.Args = append([]string{"reduce"}, args...)
	}
	return cli.cmd.Execute()
}

// Initialize the reduce client
func (cli *CLI) init() (err error) {
	if cli.Client == nil {
		opts := opt.Copy(cli.opts)
		cli.Client = reduce.New(opts...)
	}
	return
}
