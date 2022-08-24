GO_BINS := $(GO_BINS) cmd/foo
DOCKER_BINS := $(DOCKER_BINS) foo
# To build a docker image that can run locally on a mac, 
# run `LOCAL=true make dockerbuild`. 
ifndef LOCAL
	DOCKER_BUILD_EXTRA_FLAGS := --platform=linux/amd64
endif

LICENSE_HEADER_LICENSE_TYPE := apache
LICENSE_HEADER_COPYRIGHT_HOLDER := Lekko Technologies, Inc.
LICENSE_HEADER_YEAR_RANGE := 2022
LICENSE_HEADER_IGNORES := \/testdata

BUF_LINT_INPUT := .
BUF_FORMAT_INPUT := .

include make/go/bootstrap.mk
include make/go/go.mk
include make/go/docker.mk
include make/go/buf.mk
include make/go/license_header.mk
include make/go/dep_protoc_gen_go.mk

bufgeneratedeps:: $(BUF) $(PROTOC_GEN_GO)

.PHONY: bufgeneratecleango
bufgeneratecleango:
	rm -rf internal/gen/proto

bufgenerateclean:: bufgeneratecleango

.PHONY: bufgeneratego
bufgeneratego:
	buf generate

bufgeneratesteps:: bufgeneratego
