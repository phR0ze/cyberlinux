// Package pkgbuild provides a lexer and parser for pkgbuild files
package pkgbuild

import (
	"io"
)

// Parser for semanitic analysis of PKGBUILD files. The parser's job is to make
// the tokens are in the right order and construct an abstract syntax tree (AST)
// from our series of tokens.
// https://blog.gopheracademy.com/advent-2014/parsers-lexers/
const (

// // Keywords https://wiki.archlinux.org/index.php/PKGBUILD
// // Strings may or may not be single or double quoted
// PKGBASE      // string
// PKGNAME      // string or array in split pkg case: lowercase alphanumerics and @._+-
// PKGVER       // string: alphanumerics and ._
// PKGREL       // int: usually positive and incrementing
// EPOCH        // int: required to be positive, default 0
// PKGDESC      // string: description recommended to be 80 characters
// ARCH         // array of string:
// URL          // string
// LICENSE      // array of string:
// GROUPS       // array of string:
// DEPENDS      // array of string:
// OPTDEPENDS   // array of string:
// MAKEDEPENDS  // array of string:
// CHECKDEPENDS // array of string:
// PROVIDES     // array of string:
// CONFLICTS    // array of string:
// REPLACES     // array of string:
// BACKUP       // array of string:
// OPTIONS      // array of string:
// INSTALL      // string
// CHANGELOG    // string
// SOURCE       // array of string:
// NOEXTRACT    // array of string:
// VALIDPGPKEYS // array of string:
// MD5SUMS      // array of string:
// SHA1SUMS     // array of string:
// SHA256SUMS   // array of string:
// SHA224SUMS   // array of string:
// SHA384SUMS   // array of string:
// SHA512SUMS   // array of string:
)

// Parse the given PKGBUILD reader
func Parse(reader io.Reader) {
	// scanner := &Scanner{reader: bufio.NewReader(reader)}

	// for scanner.Next() {
	// 	token := scanner.token
	// 	fmt.Println("Type: ", token.Type)
	// 	fmt.Println("Pos : ", token.Pos)
	// 	fmt.Println("Text: ", token.Text)
	// }
}
