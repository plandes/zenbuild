## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/tex.mk

.PHONY:		compile
build:		texpdf

.PHONY:		deploy
deploy:		texfinal

.PHONY:		show
show:		texreposition
