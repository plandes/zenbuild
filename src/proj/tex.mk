## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/tex.mk

.PHONY:		compile
compile:	texpdf

.PHONY:		package
package:	texpackage

.PHONY:		install
install:	texinstall

.PHONY:		dist
dist:		texinstall

.PHONY:		export
export:		texexport

.PHONY:		show
show:		texreposition

.PHONY:		open
open:		texshowpdf

.PHONY:		present
present:	texpresent
