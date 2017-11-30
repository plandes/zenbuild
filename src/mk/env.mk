## project make include
## include one of the files from ../proj instead of htis

BUILD_INC=	$(realpath $(shell pwd)/$(ZBHOME))
PROJ_TYPE ?=	default
MTARG ?=	target

## includes
include $(BUILD_INC)/src/proj/$(PROJ_TYPE).mk
include $(BUILD_INC)/src/mk/clean.mk
