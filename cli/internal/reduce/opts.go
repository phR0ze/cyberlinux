package reduce

import (
	"github.com/phR0ze/cyberlinux/cli/internal/arch/aur"
	"github.com/phR0ze/n/pkg/opt"
)

// Options
var (
	CleanOptKey       = "clean"
	DeploymentsOptKey = "deployments"
	ProfileOptKey     = "profile"
	RootOptKey        = "root"
	AurClientOptKey   = "aur-client"
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

// ProfileOpt passes the profile string
func ProfileOpt(val string) *opt.Opt {
	return &opt.Opt{Key: ProfileOptKey, Val: val}
}

// GetProfileOpt return the profile
func GetProfileOpt(opts []*opt.Opt) string {
	if o := opt.Get(opts, ProfileOptKey); o != nil {
		if val, ok := o.Val.(string); ok {
			return val
		}
	}
	return ""
}

// RootOpt passes the root string
func RootOpt(val string) *opt.Opt {
	return &opt.Opt{Key: RootOptKey, Val: val}
}

// GetRootOpt return the root
func GetRootOpt(opts []*opt.Opt) string {
	if o := opt.Get(opts, RootOptKey); o != nil {
		if val, ok := o.Val.(string); ok {
			return val
		}
	}
	return ""
}

// AurClientOpt passes the client to use
func AurClientOpt(val aur.Interface) *opt.Opt {
	return &opt.Opt{Key: AurClientOptKey, Val: val}
}

// GetAurClientOpt returns the client option
func GetAurClientOpt(opts []*opt.Opt) aur.Interface {
	if o := opt.Get(opts, AurClientOptKey); o != nil {
		if val, ok := o.Val.(aur.Interface); ok {
			return val
		}
	}
	return nil
}

// DefaultAurClientOpt sets the default client if it doesn't exist
func DefaultAurClientOpt(opts []*opt.Opt, val aur.Interface) aur.Interface {
	if !opt.Exists(opts, AurClientOptKey) {
		return val
	}
	return GetAurClientOpt(opts)
}
