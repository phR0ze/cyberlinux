package reduce

import "github.com/phR0ze/n/pkg/opt"

// Fake instance
type Fake struct {
	opt.StdProps
	Data   map[string]interface{} // test data input
	Result map[string]interface{} // test data output
}

// NewFake initializes the new instance with the given options
func NewFake(opts ...*opt.Opt) Interface {
	fake := &Fake{}
	fake.In = opt.GetInOpt(opts)
	fake.Out = opt.GetOutOpt(opts)
	fake.Err = opt.GetErrOpt(opts)
	fake.Home = opt.GetHomeOpt(opts)
	fake.Quiet = opt.GetQuietOpt(opts)
	fake.Debug = opt.GetDebugOpt(opts)
	fake.DryRun = opt.GetDryRunOpt(opts)
	fake.Data = map[string]interface{}{}
	fake.Result = map[string]interface{}{}

	return fake
}

// Clean reduce targets
func (fake *Fake) Clean(targets []string) error {
	fake.Result["clean"] = targets

	if data, ok := fake.Data["clean"]; ok {
		switch x := data.(type) {
		case error:
			return x
		}
	}
	return nil
}

// Build reduce targets
func (fake *Fake) Build(targets []string, opts ...*opt.Opt) (err error) {
	fake.Result["build"] = targets
	fake.Result["build-opts"] = opts

	if data, ok := fake.Data["build"]; ok {
		switch x := data.(type) {
		case error:
			return x
		}
	}
	return nil
}
