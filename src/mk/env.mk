## project make include
## include one of the files from ../proj instead of htis

# functions
DIRNAME_FN=	$(patsubst %/,%,$(dir $1))

# build environment
BUILD_MK_DIR :=	$(realpath $(call DIRNAME_FN,$(lastword $(MAKEFILE_LIST))))
BUILD_SRC_DIR:=	$(call DIRNAME_FN,$(BUILD_MK_DIR))
BUILD_HOME_DIR:=$(call DIRNAME_FN,$(BUILD_SRC_DIR))

# executables
GTAGUTIL=	$(BUILD_HOME_DIR)/src/python/gtagutil
AWSENV=		$(BUILD_HOME_DIR)/src/python/awsenv

# build defaults
PROJ_TYPE ?=	default
MTARG ?=	target

## includes
include $(BUILD_SRC_DIR)/proj/$(PROJ_TYPE).mk
include $(BUILD_MK_DIR)/clean.mk

## targets
.PHONY:	envinfo
envinfo:
	@echo "build-home: $(BUILD_HOME_DIR)"
