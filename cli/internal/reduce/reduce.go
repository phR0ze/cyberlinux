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
	Clean(targets []string) error                   // Clean reduce targets
	Build(targets []string, opts ...*opt.Opt) error // Build reduce targets
}

// New initializes the new instance with the given options
func New(opts ...*opt.Opt) Interface {
	reduce := &Reduce{}
	reduce.In = opt.GetInOpt(opts)
	reduce.Out = opt.GetOutOpt(opts)
	reduce.Err = opt.GetErrOpt(opts)
	reduce.Home = opt.GetHomeOpt(opts)
	reduce.Quiet = opt.GetQuietOpt(opts)
	reduce.Debug = opt.GetDebugOpt(opts)
	reduce.DryRun = opt.GetDryRunOpt(opts)

	return reduce
}
