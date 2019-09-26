package main

import (
	"fmt"

	"github.com/sirupsen/logrus"
)

// Setup log formatting
func (cli *CLI) setupLogging() {
	logrus.SetFormatter(&logrus.TextFormatter{
		FullTimestamp:   true,
		TimestampFormat: "02-01-2006 15:04:05",
	})
	logrus.SetOutput(cli.Out)
	logrus.SetLevel(logrus.InfoLevel)
}

// Helper function to print or not
func (cli *CLI) println(a ...interface{}) {
	if !cli.Quiet {
		fmt.Fprintln(cli.Out, a...)
	}
}

// Helper function to printf or not
func (cli *CLI) printf(format string, a ...interface{}) {
	if !cli.Quiet {
		fmt.Fprintf(cli.Out, format, a...)
	}
}

// LogError is a helper function to trigger logging at the top level
func (cli *CLI) LogError(msg string, a ...interface{}) {
	logrus.Error(fmt.Sprintf(msg, a...))
}

// LogFatal exposes logging to caller for testing
func (cli *CLI) LogFatal(err error) {
	if cli.Debug {
		logrus.Fatalf("%+v", err)
	} else {
		logrus.Fatalf("%v", err)
	}
}
