package reduce

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestBuild_InvalidParams(t *testing.T) {
	reset()

	// invalid targets
	{
		reduce, err := newReduce()
		assert.Nil(t, err)
		err = reduce.Build([]string{"foo"}, ProfileOpt("foo"))
		assert.Equal(t, "Invalid targets given", err.Error())
	}

	// invalid profile
	{
		reduce, err := newReduce()
		assert.Nil(t, err)
		err = reduce.Build([]string{"bob"})
		assert.Equal(t, "Profile not specified", err.Error())
	}
}
