## project make include
## include one of the files from ../proj instead of htis

# build environment
BUILD_HOME_DIR :=	$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_SRC_DIR :=	$(BUILD_HOME_DIR)/src
BUILD_BIN_DIR :=	$(BUILD_HOME_DIR)/bin
BUILD_MK_DIR :=		$(BUILD_SRC_DIR)/mk

# to be included
PROJ_MKS =		$(addsuffix .mk,$(addprefix $(BUILD_MK_DIR)/,$(PROJ_MODULES) clean git))

# executables
AWSENV=			$(BUILD_BIN_DIR)/awsenv

# build defaults
PROJ_TYPE ?=		default
MTARG ?=		$(abspath ./target)

## targets
all:			info

## includes
include $(BUILD_SRC_DIR)/proj/$(PROJ_TYPE).mk
include $(PROJ_MKS)

## print build information
.PHONY:	info
info:	$(INFO_TARGETS)
	@echo "project-modules: $(PROJ_MODULES)"
	@echo "module-include-files: $(PROJ_MKS)"
	@echo "info-targs: $(INFO_TARGETS)"
	@echo "build-home: $(BUILD_HOME_DIR)"
