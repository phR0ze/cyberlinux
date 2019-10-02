package reduce

import (
	"bytes"
	"path"
	"testing"

	"github.com/phR0ze/n/pkg/opt"
	"github.com/phR0ze/n/pkg/sys"
	"github.com/stretchr/testify/assert"
)

const (
	testDir = "../../test"
	tempDir = "../../test/temp"
)

func newReduce(opts ...*opt.Opt) (reduce *Reduce, err error) {
	opt.Default(&opts, RootOpt(tempDir))
	opt.Default(&opts, opt.QuietOpt(true))
	opt.Default(&opts, opt.TestingOpt(true))
	opt.Default(&opts, opt.OutOpt(&bytes.Buffer{}))
	opt.Default(&opts, opt.ErrOpt(&bytes.Buffer{}))
	var ins Interface
	if ins, err = New(opts...); err != nil {
		return
	}
	reduce = ins.(*Reduce)
	return
}

func reset() {
	sys.RemoveAll(tempDir)
	sys.MkdirP(tempDir)
}

func TestCreateDirs(t *testing.T) {
	reset()

	reduce, err := newReduce()
	assert.Nil(t, err)

	dirs, err := sys.AllDirs(tempDir)
	assert.Equal(t, []string(nil), dirs)
	reduce.createDirs()

	dirs, err = sys.AllDirs(tempDir)
	for i, dir := range dirs {
		dirs[i] = sys.SlicePath(dir, -3, -1)
	}
	assert.Equal(t, []string{"test/temp/temp", "temp/temp/pacman", "temp/pacman/cache", "temp/temp/work", "temp/work/_iso_", "temp/work/tmp", "test/temp/vagrant"}, dirs)
}

func TestGetRootPath(t *testing.T) {
	reset()

	// get root from passed in value
	{
		reduce, err := newReduce()
		assert.Nil(t, err)
		err = reduce.getRootDir()
		assert.Nil(t, err)
		assert.Equal(t, tempDir, reduce.rootDir)
	}

	// get root from cwd
	{
		reduce, err := New()
		assert.Nil(t, err)
		err = reduce.(*Reduce).getRootDir()
		assert.Nil(t, err)
		assert.Equal(t, gKeys.cyberlinux, path.Base(reduce.(*Reduce).rootDir))
	}
}
