#@meta {author: "Paul Landes"}
#@meta {desc: "entry point include file", date: "2025-04-22"}
#@meta {doc: "include one of the files from ../proj instead of this"}


## Build
#
# substitution utility
null :=
comma :=		,
space := 		${null} ${null}

# enable make debugging statements
BUILD_DEBUG :=		0

# build environment
BUILD_HOME_DIR :=	$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_SRC_DIR :=	$(BUILD_HOME_DIR)/src
BUILD_BIN_DIR :=	$(BUILD_HOME_DIR)/bin
BUILD_MK_DIR :=		$(BUILD_SRC_DIR)/mk

# to be included (PROJ_LOCAL_MODULES include variables needed to be defined
# before targets)
PROJ_LOCAL_MKS =	$(addsuffix .mk,$(addprefix $(BUILD_MK_DIR)/,$(PROJ_LOCAL_MODULES)))

# to be included
PROJ_MKS =		$(addsuffix .mk,$(addprefix $(BUILD_MK_DIR)/,$(PROJ_MODULES) clean))

# executables
AWSENV=			$(BUILD_BIN_DIR)/awsenv

# build defaults
PROJ_TYPE ?=		default
MTARG ?=		$(abspath ./target)
APP_INST_DIR ?=		./inst

# default programs
RENDER_BIN ?=		$(PYTHON_UTIL_HOME)/bin/rend


## Default targets
#
all:			info


## Includes
#
# local site configuration if it exists
-include $(HOME)/.zenbuild.mk
# local settings used by the project
include $(PROJ_LOCAL_MKS)
# main project include (i.e. python)
include $(BUILD_SRC_DIR)/proj/$(PROJ_TYPE).mk
# includes dependent on the project
include $(PROJ_MKS)


## Targets
#
## print build information
.PHONY:	info
info:	$(INFO_TARGETS)
	@echo "project-modules: $(PROJ_MODULES)"
	@echo "module-include-files: $(PROJ_MKS)"
	@echo "info-targs: $(INFO_TARGETS)"
	@echo "build-home: $(BUILD_HOME_DIR)"
