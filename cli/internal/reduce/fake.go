package reduce

import (
	"bytes"

	"github.com/phR0ze/n/pkg/opt"
)

// Fake instance
type Fake struct {
	Reduce
	Data   map[string]interface{} // test data input
	Result map[string]interface{} // test data output
}

// NewFake initializes the new instance with the given options
func NewFake(opts ...*opt.Opt) (ins Interface, err error) {
	opt.Default(&opts, opt.QuietOpt(true))
	opt.Default(&opts, opt.TestingOpt(true))
	opt.Default(&opts, opt.OutOpt(&bytes.Buffer{}))
	opt.Default(&opts, opt.ErrOpt(&bytes.Buffer{}))

	fake := &Fake{}
	fake.Data = map[string]interface{}{}
	fake.Result = map[string]interface{}{}
	if ins, err = New(opts...); err != nil {
		return
	}
	fake.Reduce = *(ins.(*Reduce))

	ins = fake
	return
}

// Clean reduce targets
func (fake *Fake) Clean(targets []string, opts ...*opt.Opt) error {
	fake.Result["clean-targets"] = targets
	fake.Result["clean-opts"] = opts

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
	fake.Result["build-targets"] = targets
	fake.Result["build-opts"] = opts

	if data, ok := fake.Data["build"]; ok {
		switch x := data.(type) {
		case error:
			return x
		}
	}
	return nil
}
