package main

import (
	"fmt"

	"github.com/spf13/cobra"
)

// ArgsError implementes the Error interface
// used as a way to determine if usage should be printed out
type ArgsError struct {
	Command *cobra.Command
	Message string
}

// NewArgsError creates a new ArgsError with the given message
func NewArgsError(cmd *cobra.Command, msg string, a ...interface{}) error {
	return ArgsError{cmd, fmt.Sprintf("Argument details: "+msg, a...)}
}

// Error implements the Error interface
func (err ArgsError) Error() string {
	return err.Message
}

// NoArgs returns an error if any args are included.
func NoArgs(cmd *cobra.Command, args []string) error {
	if err := cobra.NoArgs(cmd, args); err != nil {
		return NewArgsError(cmd, err.Error())
	}
	return nil
}

// OnlyValidArgs returns an error if any args are not in the list of ValidArgs.
func OnlyValidArgs(cmd *cobra.Command, args []string) error {
	if err := cobra.OnlyValidArgs(cmd, args); err != nil {
		return NewArgsError(cmd, err.Error())
	}
	return nil
}

// MinimumNArgs returns an error if there is not at least N args.
func MinimumNArgs(n int) cobra.PositionalArgs {
	return func(cmd *cobra.Command, args []string) error {
		if len(args) < n {
			return NewArgsError(cmd, "requires at least %d arg(s), only received %d", n, len(args))
		}
		return nil
	}
}

// MaximumNArgs returns an error if there are more than N args.
func MaximumNArgs(n int) cobra.PositionalArgs {
	return func(cmd *cobra.Command, args []string) error {
		if len(args) > n {
			return NewArgsError(cmd, "accepts at most %d arg(s), received %d", n, len(args))
		}
		return nil
	}
}

// ExactArgs returns an error if there are not exactly n args.
func ExactArgs(n int) cobra.PositionalArgs {
	return func(cmd *cobra.Command, args []string) error {
		if len(args) != n {
			return NewArgsError(cmd, "accepts %d arg(s), received %d", n, len(args))
		}
		return nil
	}
}

// RangeArgs returns an error if the number of args is not within the expected range.
func RangeArgs(min int, max int) cobra.PositionalArgs {
	return func(cmd *cobra.Command, args []string) error {
		if len(args) < min || len(args) > max {
			return NewArgsError(cmd, "accepts between %d and %d arg(s), received %d", min, max, len(args))
		}
		return nil
	}
}
