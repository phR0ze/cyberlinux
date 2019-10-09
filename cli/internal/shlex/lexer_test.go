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
	comment1 := Token{Type: COMMENT, Tokens: []Token(nil), Pos: buf.Position{0, 0, 0}, Text: "# comment\n"}
	assert.Equal(t, comment1, scanner.Scan())
	assert.Equal(t, comment1, scanner.Current())
	assert.Len(t, scanner.Tokens, 1)

	// Scan and check newline1
	newline1 := Token{Type: EOL, Tokens: []Token(nil), Pos: buf.Position{1, 0, 10}, Text: "\n"}
	assert.Equal(t, newline1, scanner.Scan())
	assert.Equal(t, newline1, scanner.Current())
	assert.Len(t, scanner.Tokens, 2)

	// Scan and check ident1
	ident1 := Token{Type: IDENT, Tokens: []Token{{Type: VARNAME, Tokens: []Token(nil), Pos: buf.Position{2, 0, 11}, Text: "foo"}}, Pos: buf.Position{2, 0, 11}, Text: "foo"}
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

func TestScanIDENT(t *testing.T) {

	// function no parens
	{
		scanner := NewScanner(strings.NewReader("foo {"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, IDENT, token.Type)
		assert.Equal(t, []Token{{Type: FUNCNAME, Tokens: []Token(nil), Pos: buf.Position{Line: 0, Col: 0}, Text: "foo"}}, token.Tokens)
		assert.Equal(t, buf.Position{}, token.Pos)
		assert.Equal(t, "foo", token.Text)
	}

	// function normal
	{
		scanner := NewScanner(strings.NewReader("foo() {"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, IDENT, token.Type)
		assert.Equal(t, []Token{{Type: FUNCNAME, Tokens: []Token(nil), Pos: buf.Position{Line: 0, Col: 0}, Text: "foo"}}, token.Tokens)
		assert.Equal(t, buf.Position{}, token.Pos)
		assert.Equal(t, "foo", token.Text)
	}

	// keyword
	{
		scanner := NewScanner(strings.NewReader("if [ x eq 1 ]"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, IDENT, token.Type)
		assert.Equal(t, []Token{{Type: KEYWORD, Tokens: []Token(nil), Pos: buf.Position{Line: 0, Col: 0}, Text: "if"}}, token.Tokens)
		assert.Equal(t, buf.Position{}, token.Pos)
		assert.Equal(t, "if", token.Text)
	}

	// underscores and numbers
	{
		scanner := NewScanner(strings.NewReader("_foo1=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, IDENT, token.Type)
		assert.Equal(t, []Token{{Type: VARNAME, Tokens: []Token(nil), Pos: buf.Position{Line: 0, Col: 0}, Text: "_foo1"}}, token.Tokens)
		assert.Equal(t, buf.Position{}, token.Pos)
		assert.Equal(t, "_foo1", token.Text)
	}

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, IDENT, token.Type)
		assert.Equal(t, []Token{{Type: VARNAME, Tokens: []Token(nil), Pos: buf.Position{Line: 0, Col: 0}, Text: "foo"}}, token.Tokens)
		assert.Equal(t, buf.Position{}, token.Pos)
		assert.Equal(t, "foo", token.Text)
	}
}

func TestScanVALUE(t *testing.T) {

	// // underscores and numbers
	// {
	// 	scanner := NewScanner(strings.NewReader("_foo1=bar"))
	// 	token := scanner.scanIDENT()
	//  assert.Equal(t, token, scanner.Current())
	// 	assert.Equal(t, IDENT, token.Type)
	// 	assert.Equal(t, []Token(nil), token.Tokens)
	// 	assert.Equal(t, "_foo1", token.Text)
	// }

	// // regular
	// {
	// 	scanner := NewScanner(strings.NewReader("foo=bar"))
	// 	token := scanner.scanIDENT()
	//  assert.Equal(t, token, scanner.Current())
	// 	assert.Equal(t, IDENT, token.Type)
	// 	assert.Equal(t, []Token(nil), token.Tokens)
	// 	assert.Equal(t, "foo", token.Text)
	// }
}

func TestScanQUOTE(t *testing.T) {

	// double mixed quote with mixed escape
	{
		scanner := NewScanner(strings.NewReader(`"fo'o' \"\'bar" bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `"fo'o' \"\'bar"`}, token)
	}

	// double mixed quote with escape
	{
		scanner := NewScanner(strings.NewReader(`"fo'o' \"bar" bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `"fo'o' \"bar"`}, token)
	}

	// double quote with escape
	{
		scanner := NewScanner(strings.NewReader(`"foo \"bar" bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `"foo \"bar"`}, token)
	}

	// double quote
	{
		scanner := NewScanner(strings.NewReader("\"foo bar\" bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `"foo bar"`}, token)
	}

	// double quote - no ending
	{
		scanner := NewScanner(strings.NewReader("\"foo bar bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Tokens: []Token(nil), Pos: buf.Position{}, Text: ``}, token)
	}

	// single mixed quote with mixed escape
	{
		scanner := NewScanner(strings.NewReader(`'fo"o" \'\"bar' bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `'fo"o" \'\"bar'`}, token)
	}

	// single mixed quote with escape
	{
		scanner := NewScanner(strings.NewReader(`'fo"o" \'bar' bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `'fo"o" \'bar'`}, token)
	}

	// single quote with escape
	{
		scanner := NewScanner(strings.NewReader(`'foo \'bar' bogus`))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: `'foo \'bar'`}, token)
	}

	// single quote
	{
		scanner := NewScanner(strings.NewReader("'foo bar' bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: QUOTE, Tokens: []Token(nil), Pos: buf.Position{}, Text: "'foo bar'"}, token)
	}

	// single quote - no ending
	{
		scanner := NewScanner(strings.NewReader("'foo bar bogus"))
		token := scanner.scanQUOTE()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL, Tokens: []Token(nil), Pos: buf.Position{}, Text: ""}, token)
	}
}

func TestScanCOMMENT(t *testing.T) {

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		token = scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// oneline eof
	{
		scanner := NewScanner(strings.NewReader("# foo bar"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: COMMENT, Tokens: []Token(nil), Pos: buf.Position{}, Text: "# foo bar"}, token)
	}

	// oneline eol
	{
		scanner := NewScanner(strings.NewReader("# foo bar\n"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: COMMENT, Tokens: []Token(nil), Pos: buf.Position{}, Text: "# foo bar\n"}, token)
	}
}

func TestScanWS(t *testing.T) {

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
		assert.Equal(t, Token{Type: WS, Tokens: []Token(nil), Pos: buf.Position{}, Text: "\t \t "}, token)
	}

	// spaces
	{
		scanner := NewScanner(strings.NewReader("  "))
		token := scanner.scanWS()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: WS, Tokens: []Token(nil), Pos: buf.Position{}, Text: "  "}, token)
	}
}

func TestScanEOL(t *testing.T) {

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
		assert.Equal(t, Token{Type: EOL, Tokens: []Token(nil), Pos: buf.Position{}, Text: "\n"}, token)

		token = scanner.scanEOL()
		assert.Equal(t, Token{Type: EOL, Tokens: []Token(nil), Pos: buf.Position{1, 0, 1}, Text: "\n"}, token)
	}

	// linux
	{
		scanner := NewScanner(strings.NewReader("\n"))
		token := scanner.scanEOL()
		assert.Equal(t, token, scanner.Current())
		assert.Equal(t, Token{Type: EOL, Tokens: []Token(nil), Pos: buf.Position{}, Text: "\n"}, token)
	}
}

func reset() {
	sys.RemoveAll(tempDir)
	sys.MkdirP(tempDir)
}
