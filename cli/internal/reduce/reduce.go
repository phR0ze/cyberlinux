package reduce

import (
	"github.com/phR0ze/n/pkg/opt"
)

// Reduce instance
type Reduce struct {
	opt.StdProps
}

// Interface is the public interface for reduce
type Interface interface {
	Clean(targets []string, opts ...*opt.Opt) error // Clean reduce targets; opts: ProfileOpt
	Build(targets []string, opts ...*opt.Opt) error // Build reduce targets; opts: ProfileOpt, CleanOpt, DeploymentsOpt
}

// New reduce client supports opt.StdProps using the options pattern
func New(opts ...*opt.Opt) Interface {
	reduce := &Reduce{}
	reduce.In = opt.GetInOpt(opts)
	reduce.Out = opt.GetOutOpt(opts)
	reduce.Err = opt.GetErrOpt(opts)
	reduce.Home = opt.GetHomeOpt(opts)
	reduce.Quiet = opt.GetQuietOpt(opts)
	reduce.Debug = opt.GetDebugOpt(opts)
	reduce.DryRun = opt.GetDryRunOpt(opts)
	reduce.Testing = opt.GetTestingOpt(opts)

	return reduce
}
