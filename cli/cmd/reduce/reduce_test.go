package main

import (
	"bytes"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
)

func newCli(opts ...*opt.Opt) (cli *CLI, err error) {
	opt.Default(&opts, opt.QuietOpt(true))
	opt.Default(&opts, opt.TestingOpt(true))
	opt.Default(&opts, opt.OutOpt(&bytes.Buffer{}))
	opt.Default(&opts, opt.ErrOpt(&bytes.Buffer{}))

	// Create a fake reduce client
	var r reduce.Interface
	if r, err = reduce.NewFake(opts...); err != nil {
		return
	}
	opt.Default(&opts, ClientOpt(r))
	cli = New(opts...)

	return
}
