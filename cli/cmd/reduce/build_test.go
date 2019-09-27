package main

import (
	"fmt"
	"testing"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/stretchr/testify/assert"
)

func TestBuidl(t *testing.T) {

	// clean & deployments
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("build", "all,iso,isofull", "personal", "--clean", "-d", "foo,bar")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all", "iso", "isofull"}, cli.Client.(*reduce.Fake).Result["build-targets"].([]string))
		assert.Len(t, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt), 3)
		assert.Equal(t, &opt.Opt{Key: reduce.CleanOptKey, Val: true}, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt)[0])
		assert.Equal(t, &opt.Opt{Key: reduce.ProfileOptKey, Val: "personal"}, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt)[1])
		assert.Equal(t, &opt.Opt{Key: reduce.DeploymentsOptKey, Val: []string{"foo", "bar"}}, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt)[2])
	}

	// many
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("build", "all,iso,isofull", "personal")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all", "iso", "isofull"}, cli.Client.(*reduce.Fake).Result["build-targets"].([]string))
	}

	// one
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("build", "all", "personal")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all"}, cli.Client.(*reduce.Fake).Result["build-targets"].([]string))
	}

	// error
	{
		cli, err := newCli()
		assert.Nil(t, err)
		cli.Client.(*reduce.Fake).Data["build"] = fmt.Errorf("internal error")
		err = cli.Execute("build", "foo", "bar")
		assert.Equal(t, "internal error", err.Error())
	}

	// invalid args
	{
		cli, err := newCli()
		assert.Nil(t, err)
		err = cli.Execute("build", "foo")
		assert.Equal(t, "Argument details: accepts 2 arg(s), received 1", err.Error())
	}
}
