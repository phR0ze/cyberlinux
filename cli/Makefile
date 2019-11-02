NAME := reduce
COLOR ?= auto # {always, auto, never}
CARGO := cargo --color ${COLOR}
VERSION := ${strip ${shell sed -En 's/.*release:.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' ../profiles/base.yml}}
GIT_BRANCH := ${strip ${shell git rev-parse --abbrev-ref HEAD 2>/dev/null}}
GIT_COMMIT := ${strip ${shell cd ..;git rev-parse --short HEAD 2>/dev/null}}

.PHONY: bench build check clean doc install publish run test update

build:
	@${CARGO} build

check:
	@${CARGO} check

release:
	@${CARGO} build --release
	@strip target/release/${NAME}

bench:
	@${CARGO} bench

doc:
	@${CARGO} doc

install: build
	@${CARGO} install

publish:
	@${CARGO} publish

run: build
	@${CARGO} run

test: build
	@${CARGO} test --all

update:
	@${CARGO} update

clean:
	@${CARGO} clean
