package shlex

// detects string manipulation runes
func isSTRMANIP(r rune) bool {
	return r == '^' || r == ',' || r == '~' || r == '#' || r == '%' || r == '/' || r == ':'
}
