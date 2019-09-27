package main

import (
	"fmt"
	"testing"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/stretchr/testify/assert"
)

func TestClean(t *testing.T) {

	// many
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("clean", "all,iso,isofull", "personal")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all", "iso", "isofull"}, cli.Client.(*reduce.Fake).Result["clean-targets"].([]string))
		assert.Len(t, cli.Client.(*reduce.Fake).Result["clean-opts"].([]*opt.Opt), 1)
		assert.Equal(t, &opt.Opt{Key: reduce.ProfileOptKey, Val: "personal"}, cli.Client.(*reduce.Fake).Result["clean-opts"].([]*opt.Opt)[0])
	}

	// one
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("clean", "all", "personal")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all"}, cli.Client.(*reduce.Fake).Result["clean-targets"].([]string))
	}

	// error
	{
		cli, err := newCli()
		assert.Nil(t, err)
		cli.Client.(*reduce.Fake).Data["clean"] = fmt.Errorf("internal error")
		err = cli.Execute("clean", "foo", "bar")
		assert.Equal(t, "internal error", err.Error())
	}

	// invalid args
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("clean", "foo")
		assert.Equal(t, "Argument details: accepts 2 arg(s), received 1", err.Error())
	}
}
