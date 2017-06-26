BINDIR      := $(shell [ -x ../../../gfxboot-compile ] && echo ../../../ )

GFXBOOT_COMPILE = $(BINDIR)gfxboot-compile
BFLAGS       = -O -v -L ../..

all: init

init: init.bc *.ps
	$(GFXBOOT_COMPILE) $(BFLAGS) -c init.bc $@

clean:
	rm -f init *.log *~

