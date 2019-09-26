package main

import (
	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
)

// Options
var (
	ClientOptKey = "client"
)

// Client option
// -------------------------------------------------------------------------------------------------

// ClientOpt passes the reduce client as an optional param
func ClientOpt(val reduce.Interface) *opt.Opt {
	return &opt.Opt{Key: ClientOptKey, Val: val}
}

// GetClientOpt return the client or nil
func GetClientOpt(opts []*opt.Opt) reduce.Interface {
	if o := opt.Get(opts, ClientOptKey); o != nil {
		if val, ok := o.Val.(reduce.Interface); ok {
			return val
		}
	}
	return nil
}
