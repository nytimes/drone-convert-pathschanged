ifndef VERSION
VERSION := $(shell git describe --always --tags)
endif

# this is the default GOPROXY value, overriding for CI/CD
export GOPROXY = proxy.golang.org,direct

# Go direct for private repos
export GOPRIVATE = github.com/nytm/*,github.com/NYTimes/*,github.com/nytimes/*

# if the vendor directory exists use it as dependency source (mainly for CI build)
ifneq (,$(wildcard ./vendor))
$(warning Found vendor directory setting go build flag to -mod vendor)
	MOD_FLAGS += -mod vendor
endif

BUILD_FLAGS = -ldflags="-X main.version=$(VERSION)"

.PHONY: help lint build build-image test testnorace
.DEFAULT_GOAL := help

# List of all targets
help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Run linter for the project
	golangci-lint run ./...

build: ## Build binary of extension
	CGO_ENABLED=0 go build ${MOD_FLAGS} -trimpath -a -v ${BUILD_FLAGS}

build-image: ## Build docker image of extension
	docker build -t drone-convert-pathschanged . -f ./docker/Dockerfile

test: ## Run all tests without race detector
	 CGO_ENABLED=0 go test ${MOD_FLAGS}  -v ./...

testrace: ## Run all tests with race detector
	 CGO_ENABLED=0 go test ${MOD_FLAGS}  -v -race ./...
