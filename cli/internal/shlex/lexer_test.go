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
	{
		file, err := os.Open(linuxPkgBuild)
		assert.Nil(t, err)
		scanner := NewScanner(file)
		assert.Equal(t, "# Maintainer: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>\n", scanner.Scan().Text)
		assert.Equal(t, "# Maintainer: Tobias Powalowski <tpowa@archlinux.org>\n", scanner.Scan().Text)
		assert.Equal(t, "# Contributor: Thomas Baechler <thomas@archlinux.org>\n", scanner.Scan().Text)
	}
}

func TestUnscan(t *testing.T) {
	scanner := NewScanner(strings.NewReader("# comment\n\nfoo=bar\nbar=foo\n"))

	// Scan and check comment1
	comment1 := Token{Type: COMMENT, Text: "# comment\n", Tokens: []Token{{Type: VALUE, Text: "# comment"}, {Type: EOL, Pos: buf.Position{0, 9, 9}, Text: "\n"}}}
	assert.Equal(t, comment1, scanner.Scan())
	assert.Equal(t, comment1, scanner.Current())
	assert.Len(t, scanner.Tokens, 1)

	// Scan and check newline1
	newline1 := Token{Type: EOL, Pos: buf.Position{1, 0, 10}, Text: "\n"}
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
		assert.Equal(t, Token{Type: COMMENT, Text: "# foo bar\n", Tokens: []Token{{Type: VALUE, Text: "# foo bar"}, {Type: EOL, Pos: buf.Position{0, 9, 9}, Text: "\n"}}}, token)
	}
}

func TestScanWS(t *testing.T) {

	// offset with none
	{
		scanner := NewScanner(strings.NewReader("\n\n"))
		token := scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: EOL, Text: "\n"}, token)

		token = scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{1, 0, 1}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("foo"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// mix
	{
		scanner := NewScanner(strings.NewReader("\t \t "))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "\t \t "}, token)
	}

	// spaces
	{
		scanner := NewScanner(strings.NewReader("  "))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)
	}
}

func TestScanEOL(t *testing.T) {

	// offset with none
	{
		scanner := NewScanner(strings.NewReader("  \n  "))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: EOL, Pos: buf.Position{0, 2, 2}, Text: "\n"}, token)

		token = scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{1, 0, 3}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("foo"))
		token := scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// multiple
	{
		scanner := NewScanner(strings.NewReader("\n\n"))
		token := scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: EOL, Text: "\n"}, token)

		token = scanner.scanEOL()
		assert.Equal(t, Token{Type: EOL, Pos: buf.Position{1, 0, 1}, Text: "\n"}, token)
	}

	// linux
	{
		scanner := NewScanner(strings.NewReader("\n"))
		token := scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: EOL, Text: "\n"}, token)
	}
}

func reset() {
	sys.RemoveAll(tempDir)
	sys.MkdirP(tempDir)
}
