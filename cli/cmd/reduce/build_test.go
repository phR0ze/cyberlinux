package main

import (
	"testing"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/phR0ze/n/pkg/opt"
	"github.com/stretchr/testify/assert"
)

func TestBuidl(t *testing.T) {
	cli := newCli()

	// clean & deployments
	{
		err := cli.Execute("build", "all", "iso", "isofull", "--clean", "-d", "foo,bar")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all", "iso", "isofull"}, cli.Client.(*reduce.Fake).Result["build"].([]string))
		assert.Len(t, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt), 2)
		assert.Equal(t, &opt.Opt{Key: reduce.CleanOptKey, Val: true}, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt)[0])
		assert.Equal(t, &opt.Opt{Key: reduce.DeploymentsOptKey, Val: []string{"foo", "bar"}}, cli.Client.(*reduce.Fake).Result["build-opts"].([]*opt.Opt)[1])
	}

	// many
	{
		err := cli.Execute("build", "all", "iso", "isofull")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all", "iso", "isofull"}, cli.Client.(*reduce.Fake).Result["build"].([]string))
	}

	// one
	{
		err := cli.Execute("build", "all")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all"}, cli.Client.(*reduce.Fake).Result["build"].([]string))
	}

	// invalid args
	{
		err := cli.Execute("build", "bob")
		assert.Equal(t, "Argument details: invalid argument \"bob\" for \"reduce build\"", err.Error())
	}
}
