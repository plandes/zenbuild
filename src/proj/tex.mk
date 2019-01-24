## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/tex.mk

.PHONY:		compile
build:		texpdf

.PHONY:		deploy
deploy:		texdist

.PHONY:		show
show:		texreposition

.PHONY:		present
present:	texpresent
