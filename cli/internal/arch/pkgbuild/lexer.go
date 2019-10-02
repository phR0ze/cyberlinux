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
	VARIABLE // name=value pair
)

// Position of the token in the document
type Position struct {
	Line   int
	Col    int
	Offset int
}

// Token encapsulates components needed to track tokens
type Token struct {
	Type TokenType
	Pos  Position
	Text string
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

	// Variable case
	default:
		s.token = s.scanVARIABLE()
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
func (s *Scanner) scanVARIABLE() (tok Token) {
	var buf bytes.Buffer

Loop:
	for {
		r := s.peek()
		switch {

		// Stop if we hit the end
		case r == eof:
			break Loop

		// Read all Bash name runes
		case isName(r):
			buf.WriteString(s.scanNAME().Text)
			break Loop

		// Must have whitespace char
		default:
			buf.WriteRune(s.read())
		}
	}

	return Token{Type: VARIABLE, Text: buf.String()}
}

// scanName consumes Bash valid variable names up to =
func (s *Scanner) scanNAME() (tok Token) {
	return s.scanFunc(NAME, func(r rune) bool { return isName(r) })
}

// scanCOMMENT consumes the current rune and all characters up and including EOL
func (s *Scanner) scanCOMMENT() (tok Token) {
	var buf bytes.Buffer

Loop:
	for {
		r := s.peek()
		switch {

		// Stop if we hit the end
		case r == eof:
			break Loop

		// Stop on EOL
		case isEOL(r):
			buf.WriteString(s.scanEOL().Text)
			break Loop

		// Read comment runes
		default:
			buf.WriteRune(s.read())
		}
	}

	return Token{Type: COMMENT, Text: buf.String()}
}

// scanEOL consumes one Linux or Windows line ending
func (s *Scanner) scanEOL() (tok Token) {
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
func (s *Scanner) scanWS() (tok Token) {
	return s.scanFunc(WS, func(r rune) bool { return isWS(r) })
}

// scanFunc provides a generic way to scan for rune sets
func (s *Scanner) scanFunc(typ TokenType, f func(rune) bool) (tok Token) {
	var buf bytes.Buffer
	for {
		if r := s.peek(); r == eof || !f(r) {
			break
		} else {
			buf.WriteRune(s.read())
		}
	}
	return Token{Type: typ, Text: buf.String()}
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
