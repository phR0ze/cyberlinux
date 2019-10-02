package pkgbuild

import (
	"bufio"
	"bytes"
	"io"
)

// Lexer is responsible for lexical analysis i.e. breaking up the PKGBUILD
// into tokens that are then fed into the parser which performs semantic
// analysis.
// https://medium.com/@farslan/a-look-at-go-scanner-packages-11710c2655fc
// https://hackthology.com/writing-a-lexer-in-go-with-lexmachine.html

// TokenType is the set of lexical tokens of the PKGBUILD format.
type TokenType int

var eof = rune(0)

// List of token types
const (
	ILLEGAL TokenType = iota

	EOF      // Errors or end of file
	EOL      // end of line handle both \r\n and \n
	WS       // one or more whitespaces
	COMMENT  // comments
	NAME     // variable name
	VALUE    // variable value
	ARRAY    // variable array value
	EQUAL    // variable equals
	VARIABLE // parent token composed of NAME, EQUAL, VALUE/ARRAY
)

// Token encapsulates components needed to track tokens
type Token struct {
	Type   TokenType
	Tokens []Token
	Text   string
}

// Scanner scans for tokens
type Scanner struct {
	token  Token         // most recently parsed token
	reader *bufio.Reader // document to scan
}

// NewScanner creates a new scanner instance
func NewScanner(reader io.Reader) *Scanner {
	return &Scanner{reader: bufio.NewReader(reader)}
}

// Scan for the the next token
func (s *Scanner) Scan() Token {
	r := s.peek()

	switch {

	// Stop if we hit the end
	case r == eof:
		s.token = Token{Type: EOF}

	// Whitespace
	case isWS(r):
		s.token = s.scanWS()

	// Comment
	case r == '#':
		s.token = s.scanCOMMENT()

		// Variable
	default:
		// s.token = s.scanVARIABLE()
	}

	return s.token
}

// Next scans for the the next token
func (s *Scanner) Next() bool {
	tok := s.Scan()
	if tok.Type != EOF {
		return true
	}
	return false
}

// peek the next rune from the reader
func (s *Scanner) peek() rune {
	ch := s.read()
	s.unread()
	return ch
}

// read the next rune from the reader
func (s *Scanner) read() rune {
	ch, _, err := s.reader.ReadRune()
	if err != nil {
		return eof
	}
	return ch
}

// unread places the previously read rune back on the reader.
func (s *Scanner) unread() { _ = s.reader.UnreadRune() }

// scanVARIABLE consumes variables e.g. name=value, name=()
func (s *Scanner) scanVARIABLE() Token {
	toks := []Token{}
	var buf bytes.Buffer

	// Scan the name
	t := s.scanNAME()
	toks = append(toks, t)
	buf.WriteString(t.Text)

	// Add the equals
	t := s.scanNAME()
	toks = append(toks, Token{Type: EQUAL, Text: "="})
	buf.WriteString(t.Text)

	// Scan the value

	t := s.scanNAME()
	toks = append(toks, t)
	buf.WriteString(t.Text)
	toks = append(toks, s.scanVALUE())
	return Token{Type: VARIABLE, Text: buf.String()}
}

// scanName consumes Bash valid variable names up to =
func (s *Scanner) scanNAME() Token {
	return s.scanFunc(NAME, func(r rune) bool { return isName(r) })
}

// scanVALUE consumes Bash variable value/array
func (s *Scanner) scanVALUE() (tok Token) {
	if r := s.peek(); r == eof {
	}
	return s.scanFunc(NAME, func(r rune) bool { return isName(r) })
}

// scanCOMMENT consumes the current rune and all characters up and including EOL
func (s *Scanner) scanCOMMENT() Token {
	var buf bytes.Buffer
	for {
		if r := s.peek(); r == eof {
			break
		} else if isEOL(r) {
			buf.WriteString(s.scanEOL().Text)
			break
		} else {
			buf.WriteRune(s.read())
		}
	}
	txt := buf.String()
	if txt == "" {
		return Token{Type: ILLEGAL, Text: txt}
	}
	return Token{Type: COMMENT, Text: txt}
}

// scanEOL consumes one Linux or Windows line ending
func (s *Scanner) scanEOL() Token {
	returns := 0
	newlines := 0
	return s.scanFunc(EOL, func(r rune) bool {
		if isEOL(r) {
			if r == '\n' {
				newlines++
			}
			if r == '\r' {
				returns++
			}
			if newlines > 1 || returns > 1 {
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
func (s *Scanner) scanFunc(typ TokenType, f func(rune) bool) Token {
	var buf bytes.Buffer
	for {
		if r := s.peek(); r == eof || !f(r) {
			break
		} else {
			buf.WriteRune(s.read())
		}
	}
	txt := buf.String()
	if txt == "" {
		return Token{Type: ILLEGAL, Text: txt}
	}
	return Token{Type: typ, Text: txt}
}

func isEOL(r rune) bool {
	return r == '\r' || r == '\n'
}

func isWS(r rune) bool {
	return r == ' ' || r == '\t' || r == '\n'
}

// Bash defines names as letters, numbers and underscores begining with a letter or underscore
func isName(r rune) bool {
	return (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || (r == '_')
}
