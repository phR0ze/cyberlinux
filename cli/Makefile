NAME = reduce
IMPORT = github.com/phR0ze/cyberlinux/cli/cmd/${NAME}
VERSION := ${strip ${shell sed -En 's/.*release:.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' ../profiles/base.yml}}
GIT_BRANCH := ${strip ${shell git rev-parse --abbrev-ref HEAD 2>/dev/null}}
GIT_COMMIT := ${strip ${shell cd ..;git rev-parse --short HEAD 2>/dev/null}}
GCFLAGS := -gcflags "all=-trimpath=${GOPATH}/src" -asmflags "all=-trimpath=${GOPATH}/src"
GOFLAGS := -ldflags '-X ${IMPORT}.VERSION=${VERSION} -X ${IMPORT}.GITCOMMIT=${GIT_COMMIT} -X ${IMPORT}.BUILDDATE=${shell date +%Y.%m.%d}'

.PHONY: build test

default: ${NAME}
${NAME}:
	@echo "Building..."
	@echo "------------------------------------------------------------------------"
	go build ${GOFLAGS} -o bin/${NAME} ./cmd/${NAME}

cover:
	@echo "Code coverage e.g. make cover pkg=internal/reduce"
	@echo "------------------------------------------------------------------------"
	go test -gcflags=-l -coverprofile=coverage.out ./${pkg}
	go tool cover -html=coverage.out
	
test:
	@echo "Testing..."
	@echo "------------------------------------------------------------------------"
	go test ./cmd/${NAME}
	go test ./internal/${NAME}
	go test ./internal/arch/abs
	go test ./internal/arch/aur

clean:
	@rm -rf bin
	@mkdir bin
