package main

import (
	"testing"

	"github.com/phR0ze/cyberlinux/cli/internal/reduce"
	"github.com/stretchr/testify/assert"
)

func TestClean(t *testing.T) {
	cli := newCli()

	// many
	{
		err := cli.Execute("clean", "all", "iso", "isofull")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all", "iso", "isofull"}, cli.Client.(*reduce.Fake).Result["clean"].([]string))
	}

	// one
	{
		err := cli.Execute("clean", "all")
		assert.Nil(t, err)
		assert.Equal(t, []string{"all"}, cli.Client.(*reduce.Fake).Result["clean"].([]string))
	}

	// invalid args
	{
		err := cli.Execute("clean", "bob")
		assert.Equal(t, "Argument details: invalid argument \"bob\" for \"reduce clean\"", err.Error())
	}
}
