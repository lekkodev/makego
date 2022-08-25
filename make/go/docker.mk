# Managed by makego. DO NOT EDIT.

# Must be set
$(call _assert_var,MAKEGO)
$(call _conditional_include,$(MAKEGO)/base.mk)
# Must be set
$(call _assert_var,PROJECT)
# Must be set
$(call _assert_var,GO_MODULE)
# Must be set
$(call _assert_var,DOCKER_ORG)
# Must be set
$(call _assert_var,DOCKER_PROJECT)

DOCKER_WORKSPACE_IMAGE := $(DOCKER_ORG)/$(DOCKER_PROJECT)-workspace
DOCKER_WORKSPACE_FILE := Dockerfile.workspace
DOCKER_WORKSPACE_DIR := /workspace

# Settable
DOCKER_BINS ?=
# Settable
DOCKER_BUILD_EXTRA_FLAGS ?=

# Runtime
DOCKERMAKETARGET ?= all

.PHONY: dockerbuildworkspace
dockerbuildworkspace:
	docker build \
		$(DOCKER_BUILD_EXTRA_FLAGS) \
		--build-arg PROJECT=$(PROJECT) \
		--build-arg GO_MODULE=$(GO_MODULE) \
		-t $(DOCKER_WORKSPACE_IMAGE) \
		-f $(DOCKER_WORKSPACE_FILE) \
		.

.PHONY: dockermakeworkspace
dockermakeworkspace: dockerbuildworkspace
	docker run -v "$(CURDIR):$(DOCKER_WORKSPACE_DIR)" $(DOCKER_WORKSPACE_IMAGE) make -j 8 $(DOCKERMAKETARGET)

ifneq (,$(findstring amd64,$(MAKECMDGOALS)))
    DOCKER_BUILD_EXTRA_FLAGS=--platform=linux/amd64
endif

.PHONY: dockerbuild
dockerbuild:: govendor

define dockerbinfunc
.PHONY: dockerbuilddeps$(1)
dockerbuilddeps$(1)::

.PHONY: dockerbuild$(1)
dockerbuild$(1): dockerbuilddeps$(1)
	docker build $(DOCKER_BUILD_EXTRA_FLAGS) -t $(DOCKER_ORG)/$(1):latest -f Dockerfile.$(1) .
ifdef EXTRA_DOCKER_ORG
	docker tag $(DOCKER_ORG)/$(1):latest $(EXTRA_DOCKER_ORG)/$(1):latest
endif

dockerbuild:: dockerbuild$(1)
endef

$(foreach dockerbin,$(sort $(DOCKER_BINS)),$(eval $(call dockerbinfunc,$(dockerbin))))

dockerbuild:: removegovendor

.PHONY: updatedockerignores
updatedockerignores:
	@rm -f .dockerignore
	@echo '# Autogenerated by makego. DO NOT EDIT.' > .dockerignore
	@$(foreach file_ignore,$(sort $(FILE_IGNORES)),echo $(file_ignore) >> .dockerignore || exit 1;)
	@$(foreach docker_file_ignore,$(sort $(DOCKER_FILE_IGNORES)),echo $(docker_file_ignore) >> .dockerignore || exit 1;)

pregenerate:: updatedockerignores
