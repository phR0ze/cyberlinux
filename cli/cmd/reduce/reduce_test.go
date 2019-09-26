package main

import (
	"bytes"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
)

func newCli(opts ...*opt.Opt) *CLI {
	opt.Default(&opts, opt.QuietOpt(true))
	opt.Default(&opts, opt.TestingOpt(true))
	opt.Default(&opts, opt.OutOpt(&bytes.Buffer{}))
	opt.Default(&opts, opt.ErrOpt(&bytes.Buffer{}))
	opt.Default(&opts, ClientOpt(reduce.NewFake()))
	c := New(opts...)
	return c
}
