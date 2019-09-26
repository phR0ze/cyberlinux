package reduce

import (
	"github.com/phR0ze/n/pkg/opt"
)

// Options
var (
	CleanOptKey       = "clean"
	DeploymentsOptKey = "deployments"
)

// CleanOpt wraps the option to clean the builds
func CleanOpt(val bool) *opt.Opt {
	return &opt.Opt{Key: CleanOptKey, Val: val}
}

// GetCleanOpt return the option to clean the build
func GetCleanOpt(opts []*opt.Opt) bool {
	if o := opt.Get(opts, CleanOptKey); o != nil {
		if val, ok := o.Val.(bool); ok {
			return val
		}
	}
	return false
}

// DeploymentsOpt wraps the deployments to build
func DeploymentsOpt(val []string) *opt.Opt {
	return &opt.Opt{Key: DeploymentsOptKey, Val: val}
}

// GetDeploymentsOpt return the deployments to build
func GetDeploymentsOpt(opts []*opt.Opt) []string {
	if o := opt.Get(opts, DeploymentsOptKey); o != nil {
		if val, ok := o.Val.([]string); ok {
			return val
		}
	}
	return []string{}
}
