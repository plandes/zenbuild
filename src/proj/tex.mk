## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/tex.mk

.PHONY:		compile
compile:	texpdf

.PHONY:		package
package:	texpackage

.PHONY:		install
install:	texinstall

.PHONY:		export
export:		texexport

.PHONY:		show
show:		texreposition

.PHONY:		present
present:	texpresent
