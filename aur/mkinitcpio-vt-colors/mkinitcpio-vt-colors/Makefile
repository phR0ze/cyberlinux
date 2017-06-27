PREFIX=/usr/local

vt-setcolors: vt-setcolors.c
	gcc -Wall vt-setcolors.c -o vt-setcolors

install: vt-setcolors vt-setcolors.1
	install -Dm 755 vt-setcolors "${DESTDIR}${PREFIX}/bin/vt-setcolors"
	install -Dm 644 vt-setcolors.1 "${DESTDIR}${PREFIX}/share/man/man1/vt-setcolors.1"

clean:
	rm vt-setcolors
