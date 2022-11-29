MAKEGO := make/go
MAKEGO_REMOTE := https://github.com/lekkodev/makego.git
PROJECT := makego
GO_MODULE := github.com/lekkodev/makego
DOCKER_ORG := lekkodev
DOCKER_PROJECT := makego
FILE_IGNORES := $(FILE_IGNORES) .vscode/

include make/foo/all.mk
