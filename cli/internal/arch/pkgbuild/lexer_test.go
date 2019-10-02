package pkgbuild

import (
	"os"
	"strings"
	"testing"

	"github.com/phR0ze/n/pkg/sys"
	"github.com/stretchr/testify/assert"
)

const (
	testDir       = "../../../test"
	tempDir       = "../../../test/temp"
	pkgBuilds     = "../../../test/pkgbuilds"
	linuxPkgBuild = "../../../test/pkgbuilds/linux"
)

func TestScan(t *testing.T) {

	// Open the pkgbuild for scanning
	{
		file, err := os.Open(linuxPkgBuild)
		assert.Nil(t, err)
		scanner := NewScanner(file)
		assert.Equal(t, "# Maintainer: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>\n", scanner.Scan().Text)
		assert.Equal(t, "# Maintainer: Tobias Powalowski <tpowa@archlinux.org>\n", scanner.Scan().Text)
		assert.Equal(t, "# Contributor: Thomas Baechler <thomas@archlinux.org>\n", scanner.Scan().Text)
		assert.Equal(t, "\n", scanner.Scan().Text)
	}
}

func TestScanNAME(t *testing.T) {

	// underscores and numbers
	{
		scanner := NewScanner(strings.NewReader("_foo1=bar"))
		token := scanner.scanNAME()
		assert.Equal(t, NAME, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "_foo1", token.Text)
	}

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanNAME()
		assert.Equal(t, NAME, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "foo", token.Text)
	}
}

func TestScanVALUE(t *testing.T) {

	// underscores and numbers
	{
		scanner := NewScanner(strings.NewReader("_foo1=bar"))
		token := scanner.scanNAME()
		assert.Equal(t, NAME, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "_foo1", token.Text)
	}

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanNAME()
		assert.Equal(t, NAME, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "foo", token.Text)
	}
}

func TestScanCOMMENT(t *testing.T) {

	// oneline eof
	{
		scanner := NewScanner(strings.NewReader("# foo bar"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, COMMENT, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "# foo bar", token.Text)
	}

	// oneline eol
	{
		scanner := NewScanner(strings.NewReader("# foo bar\n"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, COMMENT, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "# foo bar\n", token.Text)
	}
}

func TestScanWS(t *testing.T) {

	// mix
	{
		scanner := NewScanner(strings.NewReader("\n \t\n"))
		token := scanner.scanWS()
		assert.Equal(t, WS, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "\n \t\n", token.Text)
	}

	// spaces
	{
		scanner := NewScanner(strings.NewReader("  "))
		token := scanner.scanWS()
		assert.Equal(t, WS, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "  ", token.Text)
	}
}

func TestScanEOL(t *testing.T) {

	// multiple
	{
		scanner := NewScanner(strings.NewReader("\r\n\r\n"))
		token := scanner.scanEOL()
		assert.Equal(t, EOL, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "\r\n", token.Text)

		token = scanner.scanEOL()
		assert.Equal(t, EOL, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "\r\n", token.Text)
	}

	// windows
	{
		scanner := NewScanner(strings.NewReader("\r\n"))
		token := scanner.scanEOL()
		assert.Equal(t, EOL, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "\r\n", token.Text)
	}

	// linux
	{
		scanner := NewScanner(strings.NewReader("\n"))
		token := scanner.scanEOL()
		assert.Equal(t, EOL, token.Type)
		assert.Equal(t, []Token(nil), token.Tokens)
		assert.Equal(t, "\n", token.Text)
	}
}

func reset() {
	sys.RemoveAll(tempDir)
	sys.MkdirP(tempDir)
}
