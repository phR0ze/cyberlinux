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
	token := scanner.Scan()
	assert.Equal(t, Token{Type: COMMENT, Text: "# Maintainer: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>\n", Tokens: []Token{
		{Type: VALUE, Text: "# Maintainer: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>"},
		{Type: WS, Pos: buf.Position{0, 70, 70}, Text: "\n"},
	}}, token)
	assert.Equal(t, token, scanner.Current())

	// line 2
	token = scanner.Scan()
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{1, 0, 71}, Text: "# Maintainer: Tobias Powalowski <tpowa@archlinux.org>\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{1, 0, 71}, Text: "# Maintainer: Tobias Powalowski <tpowa@archlinux.org>"},
		{Type: WS, Pos: buf.Position{1, 53, 124}, Text: "\n"},
	}}, token)
	assert.Equal(t, token, scanner.Current())

	// line 3
	token = scanner.Scan()
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{2, 0, 125}, Text: "# Contributor: Thomas Baechler <thomas@archlinux.org>\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{2, 0, 125}, Text: "# Contributor: Thomas Baechler <thomas@archlinux.org>"},
		{Type: WS, Pos: buf.Position{2, 53, 178}, Text: "\n"},
	}}, token)
	assert.Equal(t, token, scanner.Current())

	// line 4
	token = scanner.Scan()
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{3, 0, 179}, Text: "\n"}, token)
	assert.Equal(t, token, scanner.Current())

	// line 5
	token = scanner.Scan()
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{4, 0, 180}, Text: `pkgbase=linux`, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{4, 0, 180}, Text: `pkgbase`},
		{Type: EQUAL, Pos: buf.Position{4, 7, 187}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{4, 8, 188}, Text: `linux`},
	}}, token)
	token = scanner.Scan()
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{4, 13, 193}, Text: "               "}, token)
	assert.Equal(t, token, scanner.Current())
	token = scanner.Scan()
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{4, 28, 208}, Text: "# Build stock -ARCH kernel\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{4, 28, 208}, Text: "# Build stock -ARCH kernel"},
		{Type: WS, Pos: buf.Position{4, 54, 234}, Text: "\n"},
	}}, token)
	assert.Equal(t, token, scanner.Current())

	// line 6
	token = scanner.Scan()
	assert.Equal(t, Token{Type: COMMENT, Pos: buf.Position{5, 0, 235}, Text: "#pkgbase=linux-custom       # Build kernel with a different name\n", Tokens: []Token{
		{Type: VALUE, Pos: buf.Position{5, 0, 235}, Text: "#pkgbase=linux-custom       # Build kernel with a different name"},
		{Type: WS, Pos: buf.Position{5, 64, 299}, Text: "\n"},
	}}, token)
	assert.Equal(t, token, scanner.Current())

	// line 7
	token = scanner.Scan()
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{6, 0, 300}, Text: `_srcver=5.3.1-arch1`, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{6, 0, 300}, Text: `_srcver`},
		{Type: EQUAL, Pos: buf.Position{6, 7, 307}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{6, 8, 308}, Text: `5.3.1-arch1`},
	}}, token)
	assert.Equal(t, token, scanner.Current())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{6, 19, 319}, Text: "\n"}, scanner.Scan())

	// line 8
	token = scanner.Scan()
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{7, 0, 320}, Text: `pkgver=${_srcver//-/.}`, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{7, 0, 320}, Text: `pkgver`},
		{Type: EQUAL, Pos: buf.Position{7, 6, 326}, Text: `=`},
		{Type: PARAM, Text: `${_srcver//-/.}`, Pos: buf.Position{7, 7, 327}, Tokens: []Token{
			{Type: DOLLAR, Pos: buf.Position{7, 7, 327}, Text: "$"},
			{Type: LCURLY, Pos: buf.Position{7, 8, 328}, Text: "{"},
			{Type: VALUE, Pos: buf.Position{7, 9, 329}, Text: `_srcver//-/.`},
			{Type: RCURLY, Pos: buf.Position{7, 21, 341}, Text: "}"},
		}},
	}}, token)
	assert.Equal(t, token, scanner.Current())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{7, 22, 342}, Text: "\n"}, scanner.Scan())

	// line 9
	token = scanner.Scan()
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{8, 0, 343}, Text: `pkgrel=1`, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{8, 0, 343}, Text: `pkgrel`},
		{Type: EQUAL, Pos: buf.Position{8, 6, 349}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{8, 7, 350}, Text: `1`},
	}}, token)
	assert.Equal(t, token, scanner.Current())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{8, 8, 351}, Text: "\n"}, scanner.Scan())

	// line 10
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{9, 0, 352}, Text: `arch=(x86_64)`, Tokens: []Token{
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
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{10, 0, 366}, Text: `url="https://git.archlinux.org/linux.git/log/?h=v$_srcver"`, Tokens: []Token{
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
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{11, 0, 425}, Text: `license=(GPL2)`, Tokens: []Token{
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
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{12, 0, 440}, Text: "makedepends=(\n  xmlto kmod inetutils bc libelf git python-sphinx python-sphinx_rtd_theme\n  graphviz imagemagick\n)", Tokens: []Token{
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
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{16, 0, 554}, Text: `options=('!strip')`, Tokens: []Token{
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

	// line 18
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{17, 0, 573}, Text: `_srcname=archlinux-linux`, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{17, 0, 573}, Text: `_srcname`},
		{Type: EQUAL, Pos: buf.Position{17, 8, 581}, Text: `=`},
		{Type: VALUE, Pos: buf.Position{17, 9, 582}, Text: `archlinux-linux`},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{17, 24, 597}, Text: "\n"}, scanner.Scan())

	// line 19-25
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{18, 0, 598}, Text: "source=(\n  \"$_srcname::git+https://git.archlinux.org/linux.git?signed#tag=v$_srcver\"\n  config         # the main kernel config file\n  60-linux.hook  # pacman hook for depmod\n  90-linux.hook  # pacman hook for initramfs regeneration\n  linux.preset   # standard config files for mkinitcpio ramdisk\n)", Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{18, 0, 598}, Text: `source`},
		{Type: EQUAL, Pos: buf.Position{18, 6, 604}, Text: `=`},
		{Type: ARRAY, Pos: buf.Position{18, 7, 605}, Text: "(\n  \"$_srcname::git+https://git.archlinux.org/linux.git?signed#tag=v$_srcver\"\n  config         # the main kernel config file\n  60-linux.hook  # pacman hook for depmod\n  90-linux.hook  # pacman hook for initramfs regeneration\n  linux.preset   # standard config files for mkinitcpio ramdisk\n)", Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{18, 7, 605}, Text: `(`},
			{Type: WS, Pos: buf.Position{18, 8, 606}, Text: "\n  "},
			{Type: QUOTE, Pos: buf.Position{19, 2, 609}, Text: `"$_srcname::git+https://git.archlinux.org/linux.git?signed#tag=v$_srcver"`, Tokens: []Token{
				{Type: LDQUOTE, Pos: buf.Position{19, 2, 609}, Text: `"`},
				{Type: VALUE, Pos: buf.Position{19, 3, 610}, Text: `$_srcname::git+https://git.archlinux.org/linux.git?signed#tag=v$_srcver`},
				{Type: RDQUOTE, Pos: buf.Position{19, 74, 681}, Text: `"`},
			}},
			{Type: WS, Pos: buf.Position{19, 75, 682}, Text: "\n  "},
			{Type: VALUE, Pos: buf.Position{20, 2, 685}, Text: `config`},
			{Type: WS, Pos: buf.Position{20, 8, 691}, Text: "         "},
			{Type: COMMENT, Pos: buf.Position{20, 17, 700}, Text: "# the main kernel config file\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{20, 17, 700}, Text: "# the main kernel config file"},
				{Type: WS, Pos: buf.Position{20, 46, 729}, Text: "\n"},
			}},
			{Type: WS, Pos: buf.Position{21, 0, 730}, Text: "  "},
			{Type: VALUE, Pos: buf.Position{21, 2, 732}, Text: `60-linux.hook`},
			{Type: WS, Pos: buf.Position{21, 15, 745}, Text: "  "},
			{Type: COMMENT, Pos: buf.Position{21, 17, 747}, Text: "# pacman hook for depmod\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{21, 17, 747}, Text: "# pacman hook for depmod"},
				{Type: WS, Pos: buf.Position{21, 41, 771}, Text: "\n"},
			}},
			{Type: WS, Pos: buf.Position{22, 0, 772}, Text: "  "},
			{Type: VALUE, Pos: buf.Position{22, 2, 774}, Text: `90-linux.hook`},
			{Type: WS, Pos: buf.Position{22, 15, 787}, Text: "  "},
			{Type: COMMENT, Pos: buf.Position{22, 17, 789}, Text: "# pacman hook for initramfs regeneration\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{22, 17, 789}, Text: "# pacman hook for initramfs regeneration"},
				{Type: WS, Pos: buf.Position{22, 57, 829}, Text: "\n"},
			}},
			{Type: WS, Pos: buf.Position{23, 0, 830}, Text: "  "},
			{Type: VALUE, Pos: buf.Position{23, 2, 832}, Text: `linux.preset`},
			{Type: WS, Pos: buf.Position{23, 14, 844}, Text: "   "},
			{Type: COMMENT, Pos: buf.Position{23, 17, 847}, Text: "# standard config files for mkinitcpio ramdisk\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{23, 17, 847}, Text: "# standard config files for mkinitcpio ramdisk"},
				{Type: WS, Pos: buf.Position{23, 63, 893}, Text: "\n"},
			}},
			{Type: RPAREN, Pos: buf.Position{24, 0, 894}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{24, 1, 895}, Text: "\n"}, scanner.Scan())

	// line 26-30
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{25, 0, 896}, Text: "validpgpkeys=(\n  'ABAF11C65A2970B130ABE3C479BE3E4300411886'  # Linus Torvalds\n  '647F28654894E3BD457199BE38DBBDC86092693E'  # Greg Kroah-Hartman\n  '8218F88849AAC522E94CF470A5E9288C4FA415FA'  # Jan Alexander Steffens (heftig)\n)", Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{25, 0, 896}, Text: `validpgpkeys`},
		{Type: EQUAL, Pos: buf.Position{25, 12, 908}, Text: `=`},
		{Type: ARRAY, Pos: buf.Position{25, 13, 909}, Text: "(\n  'ABAF11C65A2970B130ABE3C479BE3E4300411886'  # Linus Torvalds\n  '647F28654894E3BD457199BE38DBBDC86092693E'  # Greg Kroah-Hartman\n  '8218F88849AAC522E94CF470A5E9288C4FA415FA'  # Jan Alexander Steffens (heftig)\n)", Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{25, 13, 909}, Text: `(`},
			{Type: WS, Pos: buf.Position{25, 14, 910}, Text: "\n  "},
			{Type: QUOTE, Pos: buf.Position{26, 2, 913}, Text: `'ABAF11C65A2970B130ABE3C479BE3E4300411886'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{26, 2, 913}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{26, 3, 914}, Text: `ABAF11C65A2970B130ABE3C479BE3E4300411886`},
				{Type: RQUOTE, Pos: buf.Position{26, 43, 954}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{26, 44, 955}, Text: "  "},
			{Type: COMMENT, Pos: buf.Position{26, 46, 957}, Text: "# Linus Torvalds\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{26, 46, 957}, Text: "# Linus Torvalds"},
				{Type: WS, Pos: buf.Position{26, 62, 973}, Text: "\n"},
			}},
			{Type: WS, Pos: buf.Position{27, 0, 974}, Text: "  "},
			{Type: QUOTE, Pos: buf.Position{27, 2, 976}, Text: `'647F28654894E3BD457199BE38DBBDC86092693E'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{27, 2, 976}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{27, 3, 977}, Text: `647F28654894E3BD457199BE38DBBDC86092693E`},
				{Type: RQUOTE, Pos: buf.Position{27, 43, 1017}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{27, 44, 1018}, Text: "  "},
			{Type: COMMENT, Pos: buf.Position{27, 46, 1020}, Text: "# Greg Kroah-Hartman\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{27, 46, 1020}, Text: "# Greg Kroah-Hartman"},
				{Type: WS, Pos: buf.Position{27, 66, 1040}, Text: "\n"},
			}},
			{Type: WS, Pos: buf.Position{28, 0, 1041}, Text: "  "},
			{Type: QUOTE, Pos: buf.Position{28, 2, 1043}, Text: `'8218F88849AAC522E94CF470A5E9288C4FA415FA'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{28, 2, 1043}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{28, 3, 1044}, Text: `8218F88849AAC522E94CF470A5E9288C4FA415FA`},
				{Type: RQUOTE, Pos: buf.Position{28, 43, 1084}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{28, 44, 1085}, Text: "  "},
			{Type: COMMENT, Pos: buf.Position{28, 46, 1087}, Text: "# Jan Alexander Steffens (heftig)\n", Tokens: []Token{
				{Type: VALUE, Pos: buf.Position{28, 46, 1087}, Text: "# Jan Alexander Steffens (heftig)"},
				{Type: WS, Pos: buf.Position{28, 79, 1120}, Text: "\n"},
			}},
			{Type: RPAREN, Pos: buf.Position{29, 0, 1121}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{29, 1, 1122}, Text: "\n"}, scanner.Scan())

	// line 31-35
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{30, 0, 1123}, Text: "sha256sums=('SKIP'\n            '166ee15de54cd8385ed12599cf8402009df5e5c59e961e0547c7745fa385b6a2'\n            'ae2e95db94ef7176207c690224169594d49445e04249d2499e9d2fbc117a0b21'\n            'c043f3033bb781e2688794a59f6d1f7ed49ef9b13eb77ff9a425df33a244a636'\n            'ad6344badc91ad0630caacde83f7f9b97276f80d26a20619a87952be65492c65')", Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{30, 0, 1123}, Text: `sha256sums`},
		{Type: EQUAL, Pos: buf.Position{30, 10, 1133}, Text: `=`},
		{Type: ARRAY, Pos: buf.Position{30, 11, 1134}, Text: "('SKIP'\n            '166ee15de54cd8385ed12599cf8402009df5e5c59e961e0547c7745fa385b6a2'\n            'ae2e95db94ef7176207c690224169594d49445e04249d2499e9d2fbc117a0b21'\n            'c043f3033bb781e2688794a59f6d1f7ed49ef9b13eb77ff9a425df33a244a636'\n            'ad6344badc91ad0630caacde83f7f9b97276f80d26a20619a87952be65492c65')", Tokens: []Token{
			{Type: LPAREN, Pos: buf.Position{30, 11, 1134}, Text: `(`},
			{Type: QUOTE, Pos: buf.Position{30, 12, 1135}, Text: `'SKIP'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{30, 12, 1135}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{30, 13, 1136}, Text: `SKIP`},
				{Type: RQUOTE, Pos: buf.Position{30, 17, 1140}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{30, 18, 1141}, Text: "\n            "},
			{Type: QUOTE, Pos: buf.Position{31, 12, 1154}, Text: `'166ee15de54cd8385ed12599cf8402009df5e5c59e961e0547c7745fa385b6a2'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{31, 12, 1154}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{31, 13, 1155}, Text: `166ee15de54cd8385ed12599cf8402009df5e5c59e961e0547c7745fa385b6a2`},
				{Type: RQUOTE, Pos: buf.Position{31, 77, 1219}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{31, 78, 1220}, Text: "\n            "},
			{Type: QUOTE, Pos: buf.Position{32, 12, 1233}, Text: `'ae2e95db94ef7176207c690224169594d49445e04249d2499e9d2fbc117a0b21'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{32, 12, 1233}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{32, 13, 1234}, Text: `ae2e95db94ef7176207c690224169594d49445e04249d2499e9d2fbc117a0b21`},
				{Type: RQUOTE, Pos: buf.Position{32, 77, 1298}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{32, 78, 1299}, Text: "\n            "},
			{Type: QUOTE, Pos: buf.Position{33, 12, 1312}, Text: `'c043f3033bb781e2688794a59f6d1f7ed49ef9b13eb77ff9a425df33a244a636'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{33, 12, 1312}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{33, 13, 1313}, Text: `c043f3033bb781e2688794a59f6d1f7ed49ef9b13eb77ff9a425df33a244a636`},
				{Type: RQUOTE, Pos: buf.Position{33, 77, 1377}, Text: `'`},
			}},
			{Type: WS, Pos: buf.Position{33, 78, 1378}, Text: "\n            "},
			{Type: QUOTE, Pos: buf.Position{34, 12, 1391}, Text: `'ad6344badc91ad0630caacde83f7f9b97276f80d26a20619a87952be65492c65'`, Tokens: []Token{
				{Type: LQUOTE, Pos: buf.Position{34, 12, 1391}, Text: `'`},
				{Type: VALUE, Pos: buf.Position{34, 13, 1392}, Text: `ad6344badc91ad0630caacde83f7f9b97276f80d26a20619a87952be65492c65`},
				{Type: RQUOTE, Pos: buf.Position{34, 77, 1456}, Text: `'`},
			}},
			{Type: RPAREN, Pos: buf.Position{34, 78, 1457}, Text: `)`},
		}},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{34, 79, 1458}, Text: "\n\n"}, scanner.Scan())

	// line 37
	token = scanner.Scan()
	assert.Equal(t, Token{Type: VARIABLE, Pos: buf.Position{36, 0, 1460}, Text: `_kernelname=${pkgbase#linux}`, Tokens: []Token{
		{Type: VARNAME, Pos: buf.Position{36, 0, 1460}, Text: `_kernelname`},
		{Type: EQUAL, Pos: buf.Position{36, 11, 1471}, Text: `=`},
		{Type: PARAM, Text: `${pkgbase#linux}`, Pos: buf.Position{36, 12, 1472}, Tokens: []Token{
			{Type: DOLLAR, Pos: buf.Position{36, 12, 1472}, Text: "$"},
			{Type: LCURLY, Pos: buf.Position{36, 13, 1473}, Text: "{"},
			{Type: VALUE, Pos: buf.Position{36, 14, 1474}, Text: `pkgbase#linux`},
			{Type: RCURLY, Pos: buf.Position{36, 27, 1487}, Text: "}"},
		}},
	}}, token)
	assert.Equal(t, token, scanner.Current())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{36, 28, 1488}, Text: "\n"}, scanner.Scan())

	// line 38-39
	assert.Equal(t, Token{Type: NOP, Pos: buf.Position{37, 0, 1489}, Text: ":"}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{37, 1, 1490}, Text: " "}, scanner.Scan())
	assert.Equal(t, Token{Type: PARAM, Text: `${_kernelname:=-ARCH}`, Pos: buf.Position{37, 2, 1491}, Tokens: []Token{
		{Type: DOLLAR, Pos: buf.Position{37, 2, 1491}, Text: "$"},
		{Type: LCURLY, Pos: buf.Position{37, 3, 1492}, Text: "{"},
		{Type: VALUE, Pos: buf.Position{37, 4, 1493}, Text: `_kernelname:=-ARCH`},
		{Type: RCURLY, Pos: buf.Position{37, 22, 1511}, Text: "}"},
	}}, scanner.Scan())
	assert.Equal(t, Token{Type: WS, Pos: buf.Position{37, 23, 1512}, Text: "\n\n"}, scanner.Scan())

	// line 40-64
	// assert.Equal(t, Token{Type: NOP, Pos: buf.Position{37, 0, 1489}, Text: ":"}, scanner.Scan())
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
	assert.Len(t, scanner.Tokens, 2)
	assert.Equal(t, newline1, scanner.Current())

	// Unscan and rescan and check ident1
	scanner.unread(ident1)
	assert.Len(t, scanner.Tokens, 2)
	assert.Equal(t, ident1, scanner.scanIDENT())
	assert.Len(t, scanner.Tokens, 2)
	assert.Equal(t, newline1, scanner.Current())

	// Unscan and check comment1
	scanner.Unscan()
	assert.Len(t, scanner.Tokens, 1)
	assert.Equal(t, comment1, scanner.Current())

	// Unscan comment and check current
	scanner.Unscan()
	assert.Equal(t, Token{Type: ILLEGAL}, scanner.Current())
	assert.Equal(t, 0, scanner.Index)
	scanner.Unscan()
	assert.Equal(t, 0, scanner.Index)
}

func TestFirstAndLast(t *testing.T) {
	scanner := NewScanner(strings.NewReader(`foo="bar"`))

	// ILLEGAL
	assert.Equal(t, Token{Type: ILLEGAL}, scanner.First())
	assert.Equal(t, Token{Type: ILLEGAL}, scanner.Last())

	token := scanner.Scan()
	assert.Equal(t, token, scanner.First())
	assert.Equal(t, token, scanner.Last())
}

func TestScanIDENT(t *testing.T) {

	// function no parens
	{
		scanner := NewScanner(strings.NewReader("foo {"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: FUNCNAME, Text: "foo"}, token)
	}

	// function normal
	{
		scanner := NewScanner(strings.NewReader("foo() {"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: FUNCNAME, Text: "foo"}, token)
	}

	// keyword
	{
		scanner := NewScanner(strings.NewReader("if [ x eq 1 ]"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: KEYWORD, Text: "if"}, token)
	}

	// underscores and numbers
	{
		scanner := NewScanner(strings.NewReader("_foo1=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: VARNAME, Text: "_foo1"}, token)
	}

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)
	}
}

func TestScanFUNCTION(t *testing.T) {

	// regular
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)
	}
}

func TestScanVARIABLE(t *testing.T) {

	// single value quote variable
	{
		scanner := NewScanner(strings.NewReader(`foo="bar"`))
		token := scanner.scanVARIABLE()
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
		assert.Equal(t, Token{Type: VARIABLE, Text: `foo=bar`, Tokens: []Token{
			{Type: VARNAME, Text: `foo`},
			{Type: EQUAL, Pos: buf.Position{0, 3, 3}, Text: `=`},
			{Type: VALUE, Pos: buf.Position{0, 4, 4}, Text: `bar`},
		}}, token)
	}

	// single value variable
	{
		scanner := NewScanner(strings.NewReader("foo=bar"))
		token := scanner.scanVARIABLE()
		assert.Equal(t, Token{Type: VARIABLE, Text: `foo=bar`, Tokens: []Token{
			{Type: VARNAME, Text: `foo`},
			{Type: EQUAL, Pos: buf.Position{0, 3, 3}, Text: `=`},
			{Type: VALUE, Pos: buf.Position{0, 4, 4}, Text: `bar`},
		}}, token)
	}
}

func TestScanVALUE(t *testing.T) {

	// double quote
	{
		scanner := NewScanner(strings.NewReader(`foo="${bar}"`))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)

		scanner.buf.Read()
		token = scanner.scanVALUE()
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
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)

		scanner.buf.Read()
		token = scanner.scanVALUE()
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
		assert.Equal(t, Token{Type: VARNAME, Text: "foo"}, token)

		scanner.buf.Read()
		token = scanner.scanVALUE()
		assert.Equal(t, Token{Type: VALUE, Text: "bar", Pos: buf.Position{0, 4, 4}}, token)
	}
}

func TestScanPARAM(t *testing.T) {

	// ident and ${} with #
	{
		scanner := NewScanner(strings.NewReader("_kernelname=${pkgbase#linux}"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: VARNAME, Text: "_kernelname"}, token)

		scanner.buf.Read()
		token = scanner.scanPARAM()
		assert.Equal(t, Token{Type: PARAM, Text: `${pkgbase#linux}`, Pos: buf.Position{0, 12, 12}, Tokens: []Token{
			{Type: DOLLAR, Pos: buf.Position{0, 12, 12}, Text: "$"},
			{Type: LCURLY, Pos: buf.Position{0, 13, 13}, Text: "{"},
			{Type: VALUE, Pos: buf.Position{0, 14, 14}, Text: `pkgbase#linux`},
			{Type: RCURLY, Pos: buf.Position{0, 27, 27}, Text: "}"},
		}}, token)
	}

	// ident and ${} with symbols
	{
		scanner := NewScanner(strings.NewReader("pkgver=${_srcver//-/.}"))
		token := scanner.scanIDENT()
		assert.Equal(t, Token{Type: VARNAME, Text: "pkgver"}, token)

		scanner.buf.Read()
		token = scanner.scanPARAM()
		assert.Equal(t, Token{Type: PARAM, Text: `${_srcver//-/.}`, Pos: buf.Position{0, 7, 7}, Tokens: []Token{
			{Type: DOLLAR, Pos: buf.Position{0, 7, 7}, Text: "$"},
			{Type: LCURLY, Pos: buf.Position{0, 8, 8}, Text: "{"},
			{Type: VALUE, Pos: buf.Position{0, 9, 9}, Text: `_srcver//-/.`},
			{Type: RCURLY, Pos: buf.Position{0, 21, 21}, Text: "}"},
		}}, token)
	}

	// simple ${}
	{
		scanner := NewScanner(strings.NewReader("${foo}"))
		token := scanner.scanPARAM()
		assert.Equal(t, Token{Type: PARAM, Text: `${foo}`, Pos: buf.Position{0, 0, 0}, Tokens: []Token{
			{Type: DOLLAR, Pos: buf.Position{0, 0, 0}, Text: "$"},
			{Type: LCURLY, Pos: buf.Position{0, 1, 1}, Text: "{"},
			{Type: VALUE, Pos: buf.Position{0, 2, 2}, Text: `foo`},
			{Type: RCURLY, Pos: buf.Position{0, 5, 5}, Text: "}"},
		}}, token)
	}

	// simple $
	{
		scanner := NewScanner(strings.NewReader("$foo"))
		token := scanner.scanPARAM()
		assert.Equal(t, Token{Type: PARAM, Text: `$foo`, Pos: buf.Position{0, 0, 0}, Tokens: []Token{
			{Type: DOLLAR, Pos: buf.Position{0, 0, 0}, Text: "$"},
			{Type: VALUE, Pos: buf.Position{0, 1, 1}, Text: `foo`},
		}}, token)
	}

	// none with offset
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanPARAM()
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("foo"))
		token := scanner.scanPARAM()
		assert.Equal(t, Token{Type: ILLEGAL}, token)
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
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanARRAY()
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanARRAY()
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}
}

func TestScanQUOTE(t *testing.T) {

	// none with offset
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanQUOTE()
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanQUOTE()
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// double mixed quote with mixed escape
	{
		scanner := NewScanner(strings.NewReader(`"fo'o' \"\'bar" bogus`))
		token := scanner.scanQUOTE()
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
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// single mixed quote with mixed escape
	{
		scanner := NewScanner(strings.NewReader(`'fo"o" \'\"bar' bogus`))
		token := scanner.scanQUOTE()
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
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}
}

func TestScanCOMMENT(t *testing.T) {

	// none with offset
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: WS, Text: "  "}, token)

		token = scanner.scanCOMMENT()
		assert.Equal(t, Token{Type: ILLEGAL, Pos: buf.Position{0, 2, 2}}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("  foo"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}

	// oneline eof
	{
		scanner := NewScanner(strings.NewReader("# foo bar"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, Token{Type: COMMENT, Text: "# foo bar", Tokens: []Token{{Type: VALUE, Text: "# foo bar"}}}, token)
	}

	// oneline eol
	{
		scanner := NewScanner(strings.NewReader("# foo bar\n"))
		token := scanner.scanCOMMENT()
		assert.Equal(t, Token{Type: COMMENT, Text: "# foo bar\n", Tokens: []Token{{Type: VALUE, Text: "# foo bar"}, {Type: WS, Pos: buf.Position{0, 9, 9}, Text: "\n"}}}, token)
	}
}

func TestScanWS(t *testing.T) {

	// multiple mix
	{
		scanner := NewScanner(strings.NewReader("  \n  \t"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: WS, Text: "  \n  \t"}, token)
	}

	// multiple newlines
	{
		scanner := NewScanner(strings.NewReader("\n\n"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: WS, Text: "\n\n"}, token)
	}

	// single newline
	{
		scanner := NewScanner(strings.NewReader("\n"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: WS, Text: "\n"}, token)
	}

	// none
	{
		scanner := NewScanner(strings.NewReader("foo"))
		token := scanner.scanWS()
		assert.Equal(t, Token{Type: ILLEGAL}, token)
	}
}

func TestFirstIllegalToken(t *testing.T) {
	// First level
	assert.Equal(t, Token{Type: ILLEGAL}, (Token{Tokens: []Token{{Type: ILLEGAL}}}).FirstILLEGAL())

	// Second level
	assert.Equal(t, Token{Type: ILLEGAL}, (Token{Tokens: []Token{{Type: WS, Tokens: []Token{{Type: ILLEGAL}}}}}).FirstILLEGAL())
}

func TestFirstAndLastToken(t *testing.T) {
	assert.Equal(t, Token{Type: UNSET}, (Token{}).First())
	assert.Equal(t, Token{Type: UNSET}, (Token{}).Last())

	assert.Equal(t, Token{Type: WS}, (Token{Tokens: []Token{{Type: WS}}}).First())
	assert.Equal(t, Token{Type: WS}, (Token{Tokens: []Token{{Type: WS}}}).Last())
}

func reset() {
	sys.RemoveAll(tempDir)
	sys.MkdirP(tempDir)
}
