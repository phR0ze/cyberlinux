// Package shlex provides a lexer for simple shell scripting.
//
// COMMENT:
// There are three ways to use comments
// 1. Standard one line comments with hash tag #
// 2. <<HERE .... HERE  HERE Document form
// 3. : ' ... ' nop expansion
package shlex

import (
	"bytes"
	"io"
	"strings"

	"github.com/phR0ze/n/pkg/buf"
	"github.com/phR0ze/n/pkg/buf/runes"
)

// Lexer is responsible for lexical analysis i.e. breaking up the PKGBUILD
// into tokens that are then fed into the parser which performs semantic
// analysis.
// https://medium.com/@farslan/a-look-at-go-scanner-packages-11710c2655fc
// https://hackthology.com/writing-a-lexer-in-go-with-lexmachine.html

// TokenType is the set of lexical tokens of the PKGBUILD format.
type TokenType int

var (
	eof       = rune(0)
	isKeyword = map[string]bool{
		"if": true,
	}
)

// List of token types
const (
	ILLEGAL  TokenType = iota
	UNSET              // no current type
	EOF                // errors or end of file
	EOL                // end of line handle both \r\n and \n
	WS                 // one or more whitespaces
	COMMENT            // comments
	IDENT              // NAME | KEYWORD
	VARNAME            // variable name
	KEYWORD            // language operator
	FUNCNAME           // function name
	EQUAL              // assignment operator
	QUOTE              // quotes
	VALUE              // SCALAR | ARRAY | FUNC
	ARRAY              //
	VARIABLE           // IDENT, EQUAL, VALUE
)

// Token encapsulates components needed to track tokens
type Token struct {
	Type   TokenType
	Tokens []Token
	Pos    buf.Position
	Text   string
}

// Scanner scans for tokens
type Scanner struct {
	buf    *runes.Scanner // document to scan
	Index  int            // current index into the Tokens history
	Tokens []Token        // history of parsed tokens
}

// NewScanner creates a new scanner instance
func NewScanner(reader io.Reader) *Scanner {
	scanner := &Scanner{buf: runes.NewScanner(reader)}
	return scanner
}

// Current token in the tokens history slice as determined by Index
func (s *Scanner) Current() Token {
	if len(s.Tokens) > s.Index && s.Index > -1 {
		return s.Tokens[s.Index]
	}
	return Token{Type: ILLEGAL}
}

// First token in the tokens history slice
func (s *Scanner) First() Token {
	if len(s.Tokens) != 0 {
		return s.Tokens[0]
	}
	return Token{Type: ILLEGAL}
}

// Last token in the tokens history slice
func (s *Scanner) Last() Token {
	if len(s.Tokens) != 0 {
		return s.Tokens[len(s.Tokens)-1]
	}
	return Token{Type: ILLEGAL}
}

// pop the last token in the tokens history slice and update the index
func (s *Scanner) pop() Token {
	if len(s.Tokens) != 0 {
		s.Index = len(s.Tokens) - 1
		if s.Index < 0 {
			s.Index = 0
		}
		tok := s.Tokens[s.Index]
		s.Tokens = s.Tokens[0:s.Index]
		s.Index--
		if s.Index < 0 {
			s.Index = 0
		}
		return tok
	}
	return Token{Type: ILLEGAL}
}

// push token on the tokens history slice and update the Index
func (s *Scanner) push(tok Token) Token {
	s.Tokens = append(s.Tokens, tok)
	s.Index = len(s.Tokens) - 1
	return tok
}

// Scan for the the next token
func (s *Scanner) Scan() Token {
	next := s.buf.Peek()

	switch {

	// EOF
	case next == eof:
		s.push(Token{Type: EOF})

	// EOL
	case next == '\n':
		s.scanEOL()

	// Whitespace
	case isWS(next):
		s.scanWS()

	// Comment
	case next == '#':
		s.scanCOMMENT()

	// Identity
	default:
		s.scanIDENT()

		// Construct variable
		if s.Current().Type == VARNAME {
			s.Unscan()
		}
	}

	return s.Current()
}

// Unscan the previous token rewinding internal buffer, but doesn't clear the cached Token
func (s *Scanner) Unscan() {
	tok := s.Current()

	switch tok.Type {
	case EOL, WS, COMMENT, IDENT:
		for range tok.Text {
			s.buf.Unread()
		}
		s.pop()
	}
}

// scanVARIABLE consumes Bash variables <ident>=<value>
func (s *Scanner) scanVARIABLE() (tok Token) {
	var buf bytes.Buffer
	toks := []Token{}
	pos := s.buf.Pos

	// for {
	// 	var t Token
	// 	if r := s.next(); r == eof {
	// 		break
	// 	} else if r == '=' {

	// 	} else if isIDENT(r) {
	// 		t = s.scanIDENT()
	// 		toks = append(toks, t)
	// 		buf.WriteString(t.Text)
	// 	} else {
	// 		buf.WriteRune(s.read())
	// 	}

	// 	// Break out on errors
	// 	if t.Type == ILLEGAL {
	// 		break
	// 	}
	// }

	// // Check for errors
	// if t := tok.Check(); t.Type == ILLEGAL {
	// 	return t
	// } else if len(toks) != 3 {
	// 	return Token{Type: ILLEGAL, Pos: pos}
	// }
	return Token{Type: VARIABLE, Tokens: toks, Text: buf.String(), Pos: pos}
}

// scanIDENT consumes Bash identifiers i.e. variable names, keywords or function names
func (s *Scanner) scanIDENT() (tok Token) {
	tok = s.scanFunc(IDENT, func(r rune) bool { return isIDENT(r) })
	if tok.Type != ILLEGAL {
		dup := tok
		if isKEYWORD(tok.Text) {
			dup.Type = KEYWORD
		} else if s.buf.Peek() != '=' {
			dup.Type = FUNCNAME
		} else {
			dup.Type = VARNAME
		}
		tok.Tokens = []Token{dup}
		s.Tokens[s.Index] = tok
	}
	return
}

// scanVALUE consumes Bash variable value/array
// handles: no quotes, single quotes, double quotes, nested quotes and arrays
func (s *Scanner) scanVALUE() (tok Token) {
	var buf bytes.Buffer
	tok.Pos = s.buf.Pos

	for {
		if next := s.buf.Peek(); next == eof {
			break
		} else if isQUOTE(next) {
			quote := s.scanQUOTE()
			tok.Tokens = append(tok.Tokens, quote)
			buf.WriteString(quote.Text)
		} else {
			buf.WriteRune(s.buf.Read())
		}
	}

	txt := buf.String()
	if txt == "" {
		tok.Type = ILLEGAL
	} else {
		tok.Type = QUOTE
		tok.Text = txt
	}
	s.push(tok)
	return

}

// scanARRAY handle bash arrays
func (s *Scanner) scanARRAY() (tok Token) {
	var buf bytes.Buffer
	tok.Pos = s.buf.Pos
	var openParen, success bool

	for {
		if next := s.buf.Peek(); next == eof {
			break
		} else if next == '(' {
			openParen = true

		} else if next == ')' {
			if openParen {
				success = true
			}
			break
		} else {
			buf.WriteRune(s.buf.Read())
		}
	}

	if !success {
		tok.Type = ILLEGAL
	} else {
		tok.Type = ARRAY
		tok.Text = buf.String()
	}
	s.push(tok)
	return
}

// scanQUOTE handle single, double and escaped quotes;
// escaped can be backslash or quoted twice
func (s *Scanner) scanQUOTE() (tok Token) {
	var buf bytes.Buffer
	var single, double, success bool
	tok.Pos = s.buf.Pos

	for {
		prev := s.buf.PeekPrev()
		if next := s.buf.Peek(); next == eof {
			break
		} else if next == '\'' && !double && prev != '\\' {
			buf.WriteRune(s.buf.Read())
			if !single {
				single = true
			} else {
				success = true
				break
			}
		} else if next == '"' && !single && prev != '\\' {
			buf.WriteRune(s.buf.Read())
			if !double {
				double = true
			} else {
				success = true
				break
			}
		} else {
			buf.WriteRune(s.buf.Read())
		}
	}

	if !success {
		tok.Type = ILLEGAL
	} else {
		tok.Type = QUOTE
		tok.Text = buf.String()
	}
	s.push(tok)
	return
}

// scanCOMMENT consumes the current rune and all characters up and including EOL
func (s *Scanner) scanCOMMENT() (tok Token) {

	// Ensure we are working with a comment
	if s.buf.Peek() != '#' {
		tok = Token{Type: ILLEGAL, Pos: s.buf.Pos}
		s.push(tok)
	}

	// Scan the comment including the tailing newline
	tok = s.scanFunc(COMMENT, func(r rune) bool {
		if r == '\n' {
			return false
		}
		return true
	})
	if s.buf.Peek() == '\n' {
		tok.Text += string(s.buf.Read())
		s.Tokens[s.Index] = tok
	}
	return
}

// scanEOL consumes one Linux newline
func (s *Scanner) scanEOL() Token {
	newlines := 0
	return s.scanFunc(EOL, func(r rune) bool {
		if r == '\n' {
			newlines++
			if newlines > 1 {
				return false
			}
			return true
		}
		return false
	})
}

// scanWS consumes the current rune and all contiguous whitespace.
func (s *Scanner) scanWS() Token {
	return s.scanFunc(WS, func(r rune) bool { return isWS(r) })
}

// scanFunc provides a generic way to scan for rune sets
func (s *Scanner) scanFunc(typ TokenType, f func(rune) bool) (tok Token) {
	var buf bytes.Buffer
	tok.Pos = s.buf.Pos

	for {
		if r := s.buf.Peek(); r == eof || !f(r) {
			break
		} else {
			buf.WriteRune(s.buf.Read())
		}
	}

	txt := buf.String()
	if txt == "" {
		tok.Type = ILLEGAL
	} else {
		tok.Type = typ
		tok.Text = txt
	}
	s.push(tok)
	return
}

// Check simply loops over the tokens and gets the first ILLEGAL else UNSET
func (t Token) Check() Token {
	for _, tok := range t.Tokens {
		if tok.Type == ILLEGAL {
			return tok
		}
	}
	return Token{Type: UNSET}
}

// Spaces or tabs, tracking newlines as EOL
func isWS(r rune) bool {
	return r == ' ' || r == '\t'
}

func isQUOTE(r rune) bool {
	return r == '\'' || r == '"'
}

// Check if the given identity is a Bash keyword
func isKEYWORD(ident string) bool {
	if _, ok := isKeyword[strings.ToLower(ident)]; ok {
		return true
	}
	return false
}

// Bash defines names as letters, numbers and underscores begining with a letter or underscore
func isIDENT(r rune) bool {
	return (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || (r == '_')
}

// Bash puncuation
func isPunctuation(r rune) bool {
	return r == '(' || r == ')' || r == ';' || r == '<' || r == '>' || r == '|' || r == '&'
}
