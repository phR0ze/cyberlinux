package aur

import (
	"net/http"

	"github.com/phR0ze/n/pkg/opt"
)

// Options
var (
	BaseURLOptKey = "api-url"
	ClientOptKey  = "client"
)

// BaseURLOpt passes the base API URL string
func BaseURLOpt(val string) *opt.Opt {
	return &opt.Opt{Key: BaseURLOptKey, Val: val}
}

// GetBaseURLOpt returns the API URL option
func GetBaseURLOpt(opts []*opt.Opt) string {
	if o := opt.Get(opts, BaseURLOptKey); o != nil {
		if val, ok := o.Val.(string); ok {
			return val
		}
	}
	return ""
}

// DefaultBaseURLOpt sets the default API URL if it doesn't exist
func DefaultBaseURLOpt(opts []*opt.Opt, val string) string {
	if !opt.Exists(opts, BaseURLOptKey) {
		return val
	}
	return GetBaseURLOpt(opts)
}

// ClientOpt passes the client to use
func ClientOpt(val *http.Client) *opt.Opt {
	return &opt.Opt{Key: ClientOptKey, Val: val}
}

// GetClientOpt returns the client option
func GetClientOpt(opts []*opt.Opt) *http.Client {
	if o := opt.Get(opts, ClientOptKey); o != nil {
		if val, ok := o.Val.(*http.Client); ok {
			return val
		}
	}
	return nil
}

// DefaultClientOpt sets the default client if it doesn't exist
func DefaultClientOpt(opts []*opt.Opt, val *http.Client) *http.Client {
	if !opt.Exists(opts, ClientOptKey) {
		return val
	}
	return GetClientOpt(opts)
}
