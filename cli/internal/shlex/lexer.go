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
	"fmt"
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
	WS                 // one or more whitespaces
	COMMENT            // comment: COMMENT{VALUE, [EOL]}
	VARIABLE           // IDENT, EQUAL, VALUE
	EQUAL              // assignment operator

	IDENT    // NAME | KEYWORD
	VARNAME  // variable name
	KEYWORD  // language operator
	FUNCNAME // function name

	VALUE   // base primitive others encapsulate
	QUOTE   // single or double quoted value: QUOTE{LQUOTE|LDQUOTE, VALUE, RQUOTE|RDQUOTE}
	LQUOTE  // single left quote
	RQUOTE  // single right quote
	LDQUOTE // double left quote
	RDQUOTE // double right quote
	ARRAY   // array type value: ARRAY{LPAREN, VALUE|QUOTE..., RPAREN}
	LPAREN  // left parenthesis
	RPAREN  // rgiht parenthesis
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
func (s *Scanner) Scan() (tok Token) {
	next := s.buf.Peek()

	switch {

	// EOF
	case next == eof:
		tok = s.push(Token{Type: EOF})

	// Whitespace
	case isWS(next):
		tok = s.scanWS()

	// Comment
	case next == '#':
		tok = s.scanCOMMENT()

	// Identity
	default:
		if tok = s.scanIDENT(); tok.Type == ILLEGAL {
			return
		}

		// Construct variable
		if tok.Type == VARNAME {
			s.Unscan()
			tok = s.scanVARIABLE()
		}
	}

	return
}

// Unscan the previous token rewinding internal buffer, but doesn't clear the cached Token
func (s *Scanner) Unscan() {
	tok := s.Current()

	for range tok.Text {
		s.buf.Unread()
	}
	s.pop()
}

// scanVARIABLE consumes Bash variables <ident>=<value>
func (s *Scanner) scanVARIABLE() (tok Token) {
	var buf bytes.Buffer
	tok.Pos = s.buf.Pos

	equal := false
	for {
		if next := s.buf.Peek(); next == eof {
			break
		} else if !equal && isIDENT(next) {
			t := s.scanIDENT()
			tok.Tokens = append(tok.Tokens, t)
			buf.WriteString(t.Text)
		} else if next == '=' {
			equal = true
			tok.Tokens = append(tok.Tokens, Token{Type: EQUAL, Pos: s.buf.Pos, Text: string(next)})
			buf.WriteRune(s.buf.Read())
		} else if equal {
			t := s.scanVALUE()
			tok.Tokens = append(tok.Tokens, t)
			buf.WriteString(t.Text)
			break
		}
	}

	txt := buf.String()
	if txt == "" {
		tok.Type = ILLEGAL
		tok.Tokens = []Token(nil)
	} else if t := tok.FirstILLEGAL(); t.Type == ILLEGAL {
		tok = t
	} else {
		tok.Type = VARIABLE
		tok.Text = txt
	}
	s.push(tok)
	return
}

// scanIDENT consumes Bash identifiers i.e. variable names, keywords or function names
func (s *Scanner) scanIDENT() (tok Token) {
	tok = s.scanFunc(IDENT, func(r rune) bool { return isIDENT(r) })
	if tok.Type != ILLEGAL {
		if isKEYWORD(tok.Text) {
			tok.Type = KEYWORD
		} else if s.buf.Peek() == '=' {
			tok.Type = VARNAME
		} else {
			tok.Type = FUNCNAME
		}
		s.pop()
		s.push(tok)
	}
	return
}

// scanVALUE consumes a value may return VALUE | WS | QUOTE | ARRAY
func (s *Scanner) scanVALUE() (tok Token) {
	var buf bytes.Buffer
	tok.Pos = s.buf.Pos

	value := false
	for {
		if next := s.buf.Peek(); next == eof {
			break
		} else if value && isNotVALUE(next) {
			break
		} else if isQUOTE(next) {
			return s.scanQUOTE()
		} else if next == '#' {
			return s.scanCOMMENT()
		} else if next == '(' {
			return s.scanARRAY()
		} else if isNotVALUE(next) {
			break
		} else {
			value = true
			buf.WriteRune(s.buf.Read())
		}
	}

	txt := buf.String()
	if txt == "" {
		tok.Type = ILLEGAL
		tok.Tokens = []Token(nil)
	} else if t := tok.FirstILLEGAL(); t.Type == ILLEGAL {
		tok = t
	} else {
		tok.Type = VALUE
		tok.Text = txt
	}
	s.push(tok)
	return

}

// scanARRAY handle bash arrays
// composed of: ARRAY{LPAREN, VALUE|QUOTE..., RPAREN}
func (s *Scanner) scanARRAY() (tok Token) {

	// Ensure we are working the correct type
	if s.buf.Peek() != '(' {
		tok = Token{Type: ILLEGAL, Pos: s.buf.Pos}
		s.push(tok)
		return
	}

	// Scan array
	var buf bytes.Buffer
	tok.Pos = s.buf.Pos
	var openParen, success bool

	for {
		if next := s.buf.Peek(); next == eof {
			break
		} else if next == '(' {
			openParen = true
			tok.Tokens = append(tok.Tokens, Token{Type: LPAREN, Pos: s.buf.Pos, Text: string(next)})
			s.buf.Read()
		} else if next == ')' {
			pos := s.buf.Pos
			s.buf.Read()
			if openParen {
				success = true
				tok.Tokens = append(tok.Tokens, Token{Type: RPAREN, Pos: pos, Text: string(next)})
				break
			}
		} else {
			var t Token
			if isWS(next) {
				t = s.scanWS()
			} else {
				t = s.scanVALUE()
			}
			tok.Tokens = append(tok.Tokens, t)
			buf.WriteString(t.Text)
		}
	}

	if !success {
		tok.Type = ILLEGAL
		tok.Tokens = []Token(nil)
	} else if t := tok.FirstILLEGAL(); t.Type == ILLEGAL {
		tok = t
	} else {
		tok.Type = ARRAY
		tok.Text = fmt.Sprintf("%s%s%s", tok.First().Text, buf.String(), tok.Last().Text)
	}
	s.push(tok)
	return
}

// scanQUOTE handle single, double and escaped quotes, escaped can be backslash or quoted twice;
// composed of: QUOTE{LQUOTE|LDQUOTE, VALUE, RQUOTE|RDQUOTE}
func (s *Scanner) scanQUOTE() (tok Token) {

	// Ensure we are working the correct type
	if !isQUOTE(s.buf.Peek()) {
		tok = Token{Type: ILLEGAL, Pos: s.buf.Pos}
		s.push(tok)
		return
	}

	// Scan quote
	var buf bytes.Buffer
	var single, double, success bool
	tok.Pos = s.buf.Pos
	value := Token{Type: VALUE}

	for {
		prev := s.buf.PeekPrev()
		if next := s.buf.Peek(); next == eof {
			break
		} else if next == '\'' && !double && prev != '\\' {
			quote := Token{Type: LQUOTE, Pos: s.buf.Pos, Text: string(next)}
			s.buf.Read()
			if !single {
				value.Pos = s.buf.Pos
				tok.Tokens = append(tok.Tokens, quote)
				single = true
			} else {
				quote.Type = RQUOTE
				value.Text = buf.String()
				tok.Tokens = append(tok.Tokens, value)
				tok.Tokens = append(tok.Tokens, quote)
				success = true
				break
			}
		} else if next == '"' && !single && prev != '\\' {
			quote := Token{Type: LDQUOTE, Pos: s.buf.Pos, Text: string(next)}
			s.buf.Read()
			if !double {
				value.Pos = s.buf.Pos
				tok.Tokens = append(tok.Tokens, quote)
				double = true
			} else {
				quote.Type = RDQUOTE
				value.Text = buf.String()
				tok.Tokens = append(tok.Tokens, value)
				tok.Tokens = append(tok.Tokens, quote)
				success = true
				break
			}
		} else {
			buf.WriteRune(s.buf.Read())
		}
	}

	if !success || len(tok.Tokens) != 3 {
		tok.Type = ILLEGAL
		tok.Tokens = []Token(nil)
	} else if t := tok.FirstILLEGAL(); t.Type == ILLEGAL {
		tok = t
	} else {
		tok.Type = QUOTE
		tok.Text = fmt.Sprintf("%s%s%s", tok.Tokens[0].Text, tok.Tokens[1].Text, tok.Tokens[2].Text)
	}
	s.push(tok)
	return
}

// scanCOMMENT consumes the current rune and all characters up and including EOL;
// composed of: COMMENT{VALUE, [EOL]}
// There is no way to terminate a comment. It includes everything after the comment to the EOL
// including other hash symbols.
func (s *Scanner) scanCOMMENT() (tok Token) {

	// Ensure we are working the correct type
	if s.buf.Peek() != '#' {
		tok = Token{Type: ILLEGAL, Pos: s.buf.Pos}
		s.push(tok)
		return
	}

	// Scan the comment including the tailing newline
	tok = s.scanFunc(COMMENT, func(r rune) bool {
		if r == '\n' {
			return false
		}
		return true
	})
	tok.Tokens = append(tok.Tokens, Token{Type: VALUE, Pos: tok.Pos, Text: tok.Text})

	// Include newline
	if s.buf.Peek() == '\n' {
		tok.Tokens = append(tok.Tokens, Token{Type: WS, Pos: s.buf.Pos, Text: "\n"})
		tok.Text += string(s.buf.Read())
	}
	s.Tokens[s.Index] = tok
	return
}

// scanWS consumes the current rune and all contiguous whitespace;
// composed of: WS
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
	} else if t := tok.FirstILLEGAL(); t.Type == ILLEGAL {
		tok = t
	} else {
		tok.Type = typ
		tok.Text = txt
	}
	s.push(tok)
	return
}

// First token or UNSET
func (t Token) First() Token {
	if len(t.Tokens) > 0 {
		return t.Tokens[0]
	}
	return Token{Type: UNSET}
}

// Last token or UNSET
func (t Token) Last() Token {
	if len(t.Tokens) > 0 {
		return t.Tokens[len(t.Tokens)-1]
	}
	return Token{Type: UNSET}
}

// FirstILLEGAL simply loops over the tokens and gets the first ILLEGAL else UNSET
func (t Token) FirstILLEGAL() Token {
	for _, tok := range t.Tokens {
		if tok.Type == ILLEGAL {
			return tok
		}
		if _tok := tok.FirstILLEGAL(); _tok.Type == ILLEGAL {
			return _tok
		}
	}
	return Token{Type: UNSET}
}

// Spaces or tabs, tracking newlines as EOL
func isWS(r rune) bool {
	return r == ' ' || r == '\t' || r == '\n'
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

func isPUNCUATION(r rune) bool {
	return r == '(' || r == ')' || r == ';' || r == '<' || r == '>' || r == '|' || r == '&'
}

// not value chars
func isNotVALUE(r rune) bool {
	return isWS(r) || isQUOTE(r) || isPUNCUATION(r) || r == eof
}
