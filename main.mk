## project make include
## include one of the files from ../proj instead of htis

# build environment
BUILD_HOME_DIR :=	$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_SRC_DIR :=	$(BUILD_HOME_DIR)/src
BUILD_MK_DIR :=		$(BUILD_SRC_DIR)/mk

PROJ_MKS =		$(addsuffix .mk,$(addprefix $(BUILD_MK_DIR)/,$(PROJ_MODULES) clean git))

# executables
PY_TOOL_DIR=		$(BUILD_HOME_DIR)/src/python
GTAGUTIL=		$(PY_TOOL_DIR)/gtagutil
AWSENV=			$(PY_TOOL_DIR)/awsenv

# build defaults
PROJ_TYPE ?=		default
MTARG ?=		target

## targets
all:			info

## includes
include $(BUILD_SRC_DIR)/proj/$(PROJ_TYPE).mk
include $(PROJ_MKS)

.PHONY:	info
info:	$(INFO_TARGETS)
	@echo "modules: $(PROJ_MODULES)"
	@echo "module-include-files: $(PROJ_MKS)"
	@echo "info-targs: $(INFO_TARGETS)"
	@echo "build-home: $(BUILD_HOME_DIR)"
