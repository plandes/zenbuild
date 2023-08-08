## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/tex.mk

# run to find issues otherwise dropped; run show after since errors stop make
.PHONY:		debug
debug:		texdebugshow

# re-compile quickly (for references, use `package`)
.PHONY:		compile
compile:	texcompile

# force compile
.PHONY:		force
force:		texforce

# final version (i.e. don't add blind submission)
.PHONY:		final
final:		texfinal

# create a final output version, which invokes the second run if needed
# (i.e. for refernces)
.PHONY:		package
package:	texpackage

# build a final version and copy it to an install directory
.PHONY:		install
install:	texinstall

# build a final version and copy it to the install directory with a unique name
.PHONY:		installtracked
installtracked:	texinstalltracked

# another name for install
.PHONY:		dist
dist:		texinstall

# create a presentation version (i.e. for slides)
.PHONY:		present
present:	texpresent

# create a no dependency (from zenbuild) directory with files to recreate PDF
.PHONY:		export
export:		texexport

# build use macOS Preview.app to display in a specified lcoation
.PHONY:		show
show:		texshow

# build use macOS Preview.app to display in a specified lcoation
.PHONY:		finalshow
finalshow:	texfinalshow

# like show, but no reposition
.PHONY:		open
open:		texopen
