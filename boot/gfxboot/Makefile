BINDIR      := $(shell [ -x ../../gfxboot-compile ] && echo ../../ )

PREPARED     = 1
ADDDIR       = ../../bin/adddir
BFLAGS       = -O -v -L ../..

SUBDIRS      = src

THEME        = $(shell basename `pwd`)

.PHONY: all clean distclean themes $(SUBDIRS)

ifeq ($(PREPARED), 1)

  all: gfxboot.ui

else

  all:
	$(ADDDIR) ../ .
	make clean
	touch .prepared
	make

endif

themes: all

%/.ready: %
	make -C $*

src/init: src
	make -C src

gfxboot.ui: src/init data/gfxboot.cfg
	@rm -rf build
	@mkdir build
	cp -rL data/* build
	cp src/init build
	@sh -c 'cd build; chmod +t * ; chmod -t init'
	@sh -c 'cd build; echo * | sed -e "s/ /\n/g" | cpio --quiet -o >../gfxboot.ui'
	mv gfxboot.ui build

clean:
	@for i in $(SUBDIRS) ; do [ ! -f $$i/Makefile ] ||  make -C $$i clean || break ; done
	rm -rf build *~
