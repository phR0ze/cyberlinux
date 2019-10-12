package shlex

import (
	"os"
	"strings"
	"testing"

	"github.com/phR0ze/n/pkg/buf"
	"github.com/phR0ze/n/pkg/sys"
	"github.com/stretchr/testify/assert"
)

const (
	testDir       = "../../test"
	tempDir       = "../../test/temp"
	pkgBuilds     = "../../test/pkgbuilds"
	linuxPkgBuild = "../../test/pkgbuilds/linux"
)

func TestScan(t *testing.T) {

	// Open the pkgbuild for scanning
	file, err := os.Open(linuxPkgBuild)
	assert.Nil(t, err)
	scanner := NewScanner(file)

	// line 1
	assert.Equal(t, Token{Type: COMMENT, Text: "# Maintainer: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>\n", Tokens: []Token{
		{Type: VALUE, Text: "# Maintainer: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>"},
		{Type: WS, Pos: buf.Position{0, 70, 70}, Text: "\n"},
	}}, scanner.Scan())

	// line 2
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{1, 0, 71}, Text: "# Maintainer: Tobias Powalowski <tpowa@archlinux.org>\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{1, 0, 71}, Text: "# Maintainer: Tobias Powalowski <tpowa@archlinux.org>"},
		{Type: WS, Pos: buf.Position{1, 53, 124}, Text: "\n"},
	}}, scanner.Scan())

	// line 3
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{2, 0, 125}, Text: "# Contributor: Thomas Baechler <thomas@archlinux.org>\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{2, 0, 125}, Text: "# Contributor: Thomas Baechler <thomas@archlinux.org>"},
		{Type: WS, Pos: buf.Position{2, 53, 178}, Text: "\n"},
	}}, scanner.Scan())

	// line 4
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{3, 0, 179}, Text: "\n"}, scanner.Scan())

	// line 5
	assert.Equal(t, Token{Type: VARIABLE, Text: `pkgbase=linux`, Pos: buf.Position{4, 0, 180}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{4, 0, 180}, Text: `pkgbase`},
		{Type: EQUAL, Pos: buf.Position{4, 7, 187}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{4, 8, 188}, Text: `linux`},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{4, 13, 193}, Text: "               "}, scanner.Scan())
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{4, 28, 208}, Text: "# Build stock -ARCH kernel\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{4, 28, 208}, Text: "# Build stock -ARCH kernel"},
		{Type: WS, Pos: buf.Position{4, 54, 234}, Text: "\n"},
	}}, scanner.Scan())

	// line 6
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{5, 0, 235}, Text: "#pkgbase=linux-custom       # Build kernel with a different name\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{5, 0, 235}, Text: "#pkgbase=linux-custom       # Build kernel with a different name"},
		{Type: WS, Pos: buf.Position{5, 64, 299}, Text: "\n"},
	}}, scanner.Scan())

	// line 7
	assert.Equal(t, Token{Type: VARIABLE, Text: `_srcver=5.3.1-arch1`, Pos: buf.Position{6, 0, 300}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{6, 0, 300}, Text: `_srcver`},
		{Type: EQUAL, Pos: buf.Position{6, 7, 307}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{6, 8, 308}, Text: `5.3.1-arch1`},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{6, 19, 319}, Text: "\n"}, scanner.Scan())

	// line 8
	assert.Equal(t, Token{Type: VARIABLE, Text: `pkgver=${_srcver//-/.}`, Pos: buf.Position{7, 0, 320}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{7, 0, 320}, Text: `pkgver`},
		{Type: EQUAL, Pos: buf.Position{7, 6, 326}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{7, 7, 327}, Text: `${_srcver//-/.}`},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{7, 22, 342}, Text: "\n"}, scanner.Scan())

	// line 9
	assert.Equal(t, Token{Type: VARIABLE, Text: `pkgrel=1`, Pos: buf.Position{8, 0, 343}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{8, 0, 343}, Text: `pkgrel`},
		{Type: EQUAL, Pos: buf.Position{8, 6, 349}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{8, 7, 350}, Text: `1`},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{8, 8, 351}, Text: "\n"}, scanner.Scan())

	// line 10
	assert.Equal(t, Token{Type: VARIABLE, Text: `arch=(x86_64)`, Pos: buf.Position{9, 0, 352}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{9, 0, 352}, Text: `arch`},
		{Type: EQUAL, Pos: buf.Position{9, 4, 356}, Text: `=`},
		{Type: ARRAY, Text: `(x86_64)`, Pos: buf.Position{9, 5, 357}, Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{9, 5, 357}, Text: `(`},
			{Type: VALUE, Pos: buf.Position{9, 6, 358}, Text: `x86_64`},
			{Type: RPAREN, Pos: buf.Position{9, 12, 364}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{9, 13, 365}, Text: "\n"}, scanner.Scan())

	// line 11
	assert.Equal(t, Token{Type: VARIABLE, Text: `url="https://git.archlinux.org/linux.git/log/?h=v$_srcver"`, Pos: buf.Position{10, 0, 366}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{10, 0, 366}, Text: `url`},
		{Type: EQUAL, Pos: buf.Position{10, 3, 369}, Text: `=`},
		{Type: QUOTE, Pos: buf.Position{10, 4, 370}, Text: `"https://git.archlinux.org/linux.git/log/?h=v$_srcver"`, Tokens: []Token{
			{Type: LDQUOTE, Pos: buf.Position{10, 4, 370}, Text: `"`},
			{Type: VALUE, Pos: buf.Position{10, 5, 371}, Text: `https://git.archlinux.org/linux.git/log/?h=v$_srcver`},
			{Type: RDQUOTE, Pos: buf.Position{10, 57, 423}, Text: `"`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{10, 58, 424}, Text: "\n"}, scanner.Scan())

	// line 12
	assert.Equal(t, Token{Type: VARIABLE, Text: `license=(GPL2)`, Pos: buf.Position{11, 0, 425}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{11, 0, 425}, Text: `license`},
		{Type: EQUAL, Pos: buf.Position{11, 7, 432}, Text: `=`},
		{Type: ARRAY, Text: `(GPL2)`, Pos: buf.Position{11, 8, 433}, Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{11, 8, 433}, Text: `(`},
			{Type: VALUE, Pos: buf.Position{11, 9, 434}, Text: `GPL2`},
			{Type: RPAREN, Pos: buf.Position{11, 13, 438}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{11, 14, 439}, Text: "\n"}, scanner.Scan())

	// line 13 - 16
	assert.Equal(t, Token{Type: VARIABLE, Text: "makedepends=(\n  xmlto kmod inetutils bc libelf git python-sphinx python-sphinx_rtd_theme\n  graphviz imagemagick\n)", Pos: buf.Position{12, 0, 440}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{12, 0, 440}, Text: `makedepends`},
		{Type: EQUAL, Pos: buf.Position{12, 11, 451}, Text: `=`},
		{Type: ARRAY, Pos: buf.Position{12, 12, 452}, Text: "(\n  xmlto kmod inetutils bc libelf git python-sphinx python-sphinx_rtd_theme\n  graphviz imagemagick\n)", Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{12, 12, 452}, Text: `(`},
			{Type: WS, Pos: buf.Position{12, 13, 453}, Text: "\n  "},
			{Type: VALUE, Pos: buf.Position{13, 2, 456}, Text: `xmlto`},
			{Type: WS, Pos: buf.Position{13, 7, 461}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 8, 462}, Text: `kmod`},
			{Type: WS, Pos: buf.Position{13, 12, 466}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 13, 467}, Text: `inetutils`},
			{Type: WS, Pos: buf.Position{13, 22, 476}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 23, 477}, Text: `bc`},
			{Type: WS, Pos: buf.Position{13, 25, 479}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 26, 480}, Text: `libelf`},
			{Type: WS, Pos: buf.Position{13, 32, 486}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 33, 487}, Text: `git`},
			{Type: WS, Pos: buf.Position{13, 36, 490}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 37, 491}, Text: `python-sphinx`},
			{Type: WS, Pos: buf.Position{13, 50, 504}, Text: " "},
			{Type: VALUE, Pos: buf.Position{13, 51, 505}, Text: `python-sphinx_rtd_theme`},
			{Type: WS, Pos: buf.Position{13, 74, 528}, Text: "\n  "},
			{Type: VALUE, Pos: buf.Position{14, 2, 531}, Text: `graphviz`},
			{Type: WS, Pos: buf.Position{14, 10, 539}, Text: " "},
			{Type: VALUE, Pos: buf.Position{14, 11, 540}, Text: `imagemagick`},
			{Type: WS, Pos: buf.Position{14, 22, 551}, Text: "\n"},
			{Type: RPAREN, Pos: buf.Position{15, 0, 552}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{15, 1, 553}, Text: "\n"}, scanner.Scan())

	// line 17
	assert.Equal(t, Token{Type: VARIABLE, Text: `options=('!strip')`, Pos: buf.Position{16, 0, 554}, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{16, 0, 554}, Text: `options`},
		{Type: EQUAL, Pos: buf.Position{16, 7, 561}, Text: `=`},
		{Type: ARRAY, Text: `('!strip')`, Pos: buf.Position{16, 8, 562}, Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{16, 8, 562}, Text: `(`},
			{Type: QUOTE, Pos: buf.Position{16, 9, 563}, Text: `'!strip'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{16, 9, 563}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{16, 10, 564}, Text: `!strip`},
				{Type: RQUOTE, Pos: buf.Position{16, 16, 570}, Text: `'`},
			}},
			{Type: RPAREN, Pos: buf.Position{16, 17, 571}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{16, 18, 572}, Text: "\n"}, scanner.Scan())
}

func TestUnscan(t *testing.T) {
	scanner := NewScanner(strings.NewReader("# comment\n\nfoo=bar\nbar=foo\n"))

	// Scan and check comment1
	comment1 := Token{Type: COMMENT, Text: "# comment\n", Tokens: []Token{{Type: VALUE, Text: "# comment"}, {Type: WS, Pos: buf.Position{0, 9, 9}, Text: "\n"}}}
	assert.Equal(t, comment1, scanner.Scan())
	assert.Equal(t, comment1, scanner.Current())
	assert.Len(t, scanner.Tokens, 1)

	// Scan and check newline1
	newline1 := Token{Type: WS, Pos: buf.Position{1, 0, 10}, Text: "\n"}
	assert.Equal(t, newline1, scanner.Scan())
	assert.Equal(t, newline1, scanner.Current())
	assert.Len(t, scanner.Tokens, 2)

	// Scan and check ident1
	ident1 := Token{Type: VARNAME, Pos: buf.Position{2, 0, 11}, Text: "foo"}
	assert.Equal(t, ident1, scanner.scanIDENT())
	assert.Equal(t, ident1, scanner.Current())
	assert.Len(t, scanner.Tokens, 3)

	// Unscan and rescan and check ident1
	scanner.Unscan()
	assert.Equal(t, newline1, scanner.Current())
	assert.Len(t, scanner.Tokens, 2)
	assert.Equal(t, ident1, scanner.scanIDENT())
	assert.Equal(t, ident1, scanner.Current())
	assert.Len(t, scanner.Tokens, 3)

	// Unscan and check newline1
	scanner.Unscan()
	assert.Equal(t, newline1, scanner.Current())
	assert.Len(t, scanner.Tokens, 2)

	// Unscan and check comment1
	scanner.Unscan()
	assert.Equal(t, comment1, scanner.Current())
	assert.Len(t, scanner.Tokens, 1)

	scanner.Unscan()
	assert.Equal(t, Token{Type: ILLEGAL}, scanner.Current())
	assert.Equal(t, 0, scanner.Index)
	scanner.Unscan()
	assert.Equal(t, 0, scanner.Index)
}

func TestScanVARIABLE(t *testing.T) {

	// single value quote variable
	{
		scanner := NewScanner(strings.NewReader(`foo="bar"`))
		token := scanner.scanVARIABLE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARIABLE, Text: `foo="bar"`, Tokens: []Token{
			{Type: VARNAME, Text: `foo`},
			{Type: EQUAL, Pos: buf.Position{0, 3, 3}, Text: `=`},
			{Type: QUOTE, Pos: buf.Position{0, 4, 4}, Text: `"bar"`, Tokens: []Token{
				{Type: LDQUOTE, Pos: buf.Position{0, 4, 4}, Text: `"`},
				{Type: VALUE, Pos: buf.Position{0, 5, 5}, Text: `bar`},
				{Type: RDQUOTE, Pos: buf.Position{0, 8, 8}, Text: `"`},
			}},
		}}, token)
	}

	// single value variable
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanVARIABLE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARIABLE, Text: `foo=bar`, Tokens: []Token{
			{Type: VARNAME, Text: `foo`},
			{Type: EQUAL, Pos: buf.Position{0, 3, 3}, Text: `=`},
			{Type: VALUE, Pos: buf.Position{0, 4, 4}, Text: `bar`},
		}}, token)
	}
}

func TestScanIDENT(t *testing.T) {

	// function no parens
	{
		scanner := NewScanner(strings.NewReader("foo {"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: FUNCNAME, Text: "foo"}, token)
	}

	// function normal
	{
		scanner := NewScanner(strings.NewReader("foo() {"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: FUNCNAME, Text: "foo"}, token)
	}

	// keyword
	{
		scanner := NewScanner(strings.NewReader("if [ x eq 1 ]"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: KEYWORD, Text: "if"}, token)
	}

	// underscores and numbers
	{
		scanner := NewScanner(strings.NewReader("_foo1=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARNAME, Text: "_foo1"}, token)
	}

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)
	}
}

func TestScanVALUE(t *testing.T) {

	// double quote
	{
		scanner := NewScanner(strings.NewReader(`foo="${bar}"`))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)

		scanner.buf.Read()
		token = scanner.scanVALUE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `"${bar}"`, Pos: buf.Position{0, 4, 4}, Tokens: []Token{
			{Type: LDQUOTE, Pos: buf.Position{0, 4, 4}, Text: `"`},
			{Type: VALUE, Pos: buf.Position{0, 5, 5}, Text: `${bar}`},
			{Type: RDQUOTE, Pos: buf.Position{0, 11, 11}, Text: `"`},
		}}, token)
	}

	// single quote
	{
		scanner := NewScanner(strings.NewReader("foo='bar'"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)

		scanner.buf.Read()
		token = scanner.scanVALUE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `'bar'`, Pos: buf.Position{0, 4, 4}, Tokens: []Token{
			{Type: LQUOTE, Pos: buf.Position{0, 4, 4}, Text: "'"},
			{Type: VALUE, Pos: buf.Position{0, 5, 5}, Text: `bar`},
			{Type: RQUOTE, Pos: buf.Position{0, 8, 8}, Text: "'"},
		}}, token)
	}

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)

		scanner.buf.Read()
		token = scanner.scanVALUE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: VALUE, Text: "bar", Pos: buf.Position{0, 4, 4}}, token)
	}
}

func TestScanARRAY(t *testing.T) {
	// multiple spanning lines
	{
		scanner := NewScanner(strings.NewReader(`(
			xmlto kmod inetutils bc libelf git python-sphinx python-sphinx_rtd_theme
			graphviz imagemagick
		)`))

		token := scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ARRAY, Text: `(
			xmlto kmod inetutils bc libelf git python-sphinx python-sphinx_rtd_theme
			graphviz imagemagick
		)`, Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{0, 0, 0}, Text: `(`},
			{Type: WS, Pos: buf.Position{0, 1, 1}, Text: "\n\t\t\t"},
			{Type: VALUE, Pos: buf.Position{1, 3, 5}, Text: `xmlto`},
			{Type: WS, Pos: buf.Position{1, 8, 10}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 9, 11}, Text: `kmod`},
			{Type: WS, Pos: buf.Position{1, 13, 15}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 14, 16}, Text: `inetutils`},
			{Type: WS, Pos: buf.Position{1, 23, 25}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 24, 26}, Text: `bc`},
			{Type: WS, Pos: buf.Position{1, 26, 28}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 27, 29}, Text: `libelf`},
			{Type: WS, Pos: buf.Position{1, 33, 35}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 34, 36}, Text: `git`},
			{Type: WS, Pos: buf.Position{1, 37, 39}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 38, 40}, Text: `python-sphinx`},
			{Type: WS, Pos: buf.Position{1, 51, 53}, Text: " "},
			{Type: VALUE, Pos: buf.Position{1, 52, 54}, Text: `python-sphinx_rtd_theme`},
			{Type: WS, Pos: buf.Position{1, 75, 77}, Text: "\n\t\t\t"},
			{Type: VALUE, Pos: buf.Position{2, 3, 81}, Text: `graphviz`},
			{Type: WS, Pos: buf.Position{2, 11, 89}, Text: " "},
			{Type: VALUE, Pos: buf.Position{2, 12, 90}, Text: `imagemagick`},
			{Type: WS, Pos: buf.Position{2, 23, 101}, Text: "\n\t\t"},
			{Type: RPAREN, Pos: buf.Position{3, 2, 104}, Text: `)`},
		}}, token)
	}

	// multiple double quoted value
	{
		scanner := NewScanner(strings.NewReader(`("foo" "bar")`))
		token := scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ARRAY, Text: `("foo" "bar")`, Tokens: []Token{
			{Type: LPAREN, Text: `(`},
			{Type: QUOTE, Pos: buf.Position{0, 1, 1}, Text: `"foo"`, Tokens: []Token{
				{Type: LDQUOTE, Pos: buf.Position{0, 1, 1}, Text: `"`},
				{Type: VALUE, Pos: buf.Position{0, 2, 2}, Text: `foo`},
				{Type: RDQUOTE, Pos: buf.Position{0, 5, 5}, Text: `"`},
			}},
			{Type: WS, Pos: buf.Position{0, 6, 6}, Text: ` `},
			{Type: QUOTE, Pos: buf.Position{0, 7, 7}, Text: `"bar"`, Tokens: []Token{
				{Type: LDQUOTE, Pos: buf.Position{0, 7, 7}, Text: `"`},
				{Type: VALUE, Pos: buf.Position{0, 8, 8}, Text: `bar`},
				{Type: RDQUOTE, Pos: buf.Position{0, 11, 11}, Text: `"`},
			}},
			{Type: RPAREN, Pos: buf.Position{0, 12, 12}, Text: `)`},
		}}, token)
	}

	// single quoted value
	{
		scanner := NewScanner(strings.NewReader(`('foo')`))
		token := scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ARRAY, Text: `('foo')`, Tokens: []Token{
			{Type: LPAREN, Text: `(`},
			{Type: QUOTE, Pos: buf.Position{0, 1, 1}, Text: `'foo'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{0, 1, 1}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{0, 2, 2}, Text: `foo`},
				{Type: RQUOTE, Pos: buf.Position{0, 5, 5}, Text: `'`},
			}},
			{Type: RPAREN, Pos: buf.Position{0, 6, 6}, Text: `)`},
		}}, token)
	}

	// multiple values
	{
		scanner := NewScanner(strings.NewReader("(foo bar)"))
		token := scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ARRAY, Text: `(foo bar)`, Tokens: []Token{
			{Type: LPAREN, Text: `(`},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `foo`},
			{Type: WS, Pos: buf.Position{0, 4, 4}, Text: ` `},
			{Type: VALUE, Pos: buf.Position{0, 5, 5}, Text: `bar`},
			{Type: RPAREN, Pos: buf.Position{0, 8, 8}, Text: `)`},
		}}, token)
	}

	// single value
	{
		scanner := NewScanner(strings.NewReader("(foo)"))
		token := scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ARRAY, Text: `(foo)`, Tokens: []Token{
			{Type: LPAREN, Text: `(`},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `foo`},
			{Type: RPAREN, Pos: buf.Position{0, 4, 4}, Text: `)`},
		}}, token)
	}

	// none with offset
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanARRAY()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}
}

func TestScanQUOTE(t *testing.T) {

	// none with offset
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// double mixed quote with mixed escape
	{
		scanner := NewScanner(strings.NewReader(`"fo'o' \"\'bar" bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `"fo'o' \"\'bar"`, Tokens: []Token{
			{Type: LDQUOTE, Text: `"`},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `fo'o' \"\'bar`},
			{Type: RDQUOTE, Pos: buf.Position{0, 14, 14}, Text: `"`},
		}}, token)
	}

	// double mixed quote with escape
	{
		scanner := NewScanner(strings.NewReader(`"fo'o' \"bar" bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `"fo'o' \"bar"`, Tokens: []Token{
			{Type: LDQUOTE, Text: `"`},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `fo'o' \"bar`},
			{Type: RDQUOTE, Pos: buf.Position{0, 12, 12}, Text: `"`},
		}}, token)
	}

	// double quote with escape
	{
		scanner := NewScanner(strings.NewReader(`"foo \"bar" bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `"foo \"bar"`, Tokens: []Token{
			{Type: LDQUOTE, Text: `"`},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `foo \"bar`},
			{Type: RDQUOTE, Pos: buf.Position{0, 10, 10}, Text: `"`},
		}}, token)
	}

	// double quote
	{
		scanner := NewScanner(strings.NewReader("\"foo bar\" bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `"foo bar"`, Tokens: []Token{
			{Type: LDQUOTE, Text: `"`},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `foo bar`},
			{Type: RDQUOTE, Pos: buf.Position{0, 8, 8}, Text: `"`},
		}}, token)
	}

	// double quote - no ending
	{
		scanner := NewScanner(strings.NewReader("\"foo bar bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// single mixed quote with mixed escape
	{
		scanner := NewScanner(strings.NewReader(`'fo"o" \'\"bar' bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `'fo"o" \'\"bar'`, Tokens: []Token{
			{Type: LQUOTE, Text: "'"},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `fo"o" \'\"bar`},
			{Type: RQUOTE, Pos: buf.Position{0, 14, 14}, Text: "'"},
		}}, token)
	}

	// single mixed quote with escape
	{
		scanner := NewScanner(strings.NewReader(`'fo"o" \'bar' bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `'fo"o" \'bar'`, Tokens: []Token{
			{Type: LQUOTE, Text: "'"},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `fo"o" \'bar`},
			{Type: RQUOTE, Pos: buf.Position{0, 12, 12}, Text: "'"},
		}}, token)
	}

	// single quote with escape
	{
		scanner := NewScanner(strings.NewReader(`'foo \'bar' bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: `'foo \'bar'`, Tokens: []Token{
			{Type: LQUOTE, Text: "'"},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `foo \'bar`},
			{Type: RQUOTE, Pos: buf.Position{0, 10, 10}, Text: "'"},
		}}, token)
	}

	// single quote
	{
		scanner := NewScanner(strings.NewReader("'foo bar' bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Text: "'foo bar'", Tokens: []Token{
			{Type: LQUOTE, Text: "'"},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: "foo bar"},
			{Type: RQUOTE, Pos: buf.Position{0, 8, 8}, Text: "'"},
		}}, token)
	}

	// single quote - no ending
	{
		scanner := NewScanner(strings.NewReader("'foo bar bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}
}

func TestScanCOMMENT(t *testing.T) {

	// none with offset
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// oneline eof
	{
		scanner := NewScanner(strings.NewReader("# foo bar"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: COMMENT, Text: "# foo bar", Tokens: []Token{{Type: VALUE, Text: "# foo bar"}}}, token)
	}

	// oneline eol
	{
		scanner := NewScanner(strings.NewReader("# foo bar\n"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: COMMENT, Text: "# foo bar\n", Tokens: []Token{{Type: VALUE, Text: "# foo bar"}, {Type: WS, Pos: buf.Position{0, 9, 9}, Text: "\n"}}}, token)
	}
}

func TestScanWS(t *testing.T) {

	// multiple mix
	{
		scanner := NewScanner(strings.NewReader("  \n  \t"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "  \n  \t"}, token)
	}

	// multiple newlines
	{
		scanner := NewScanner(strings.NewReader("\n\n"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "\n\n"}, token)
	}

	// single newline
	{
		scanner := NewScanner(strings.NewReader("\n"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "\n"}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("foo"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}
}

func reset() {
	sys.RemoveAll(tempDir)
	sys.MkdirP(tempDir)
}
