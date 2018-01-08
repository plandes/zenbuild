## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/docker.mk

.PHONY:	compile
compile:	dockerbuild

.PHONY: install
install:	dockerpush
