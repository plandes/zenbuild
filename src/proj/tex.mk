#@meta {author: "Paul Landes"}
#@meta {desc: "build for local latex projects", date: "2025-04-27"}


## Includes
#
include $(BUILD_MK_DIR)/tex/build.mk


## Targets
#
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

# compile and view the presentation version of the file in the presentation app
.PHONY:		presentshow
presentshow:	texpresentshow

# create a no dependency (from zenbuild) directory with files to recreate PDF
.PHONY:		export
export:		texexport

# build use macOS Preview.app to display in a specified lcoation
.PHONY:		show
show:		texshow

# same as show, but don't compile first
.PHONY:		rend
rend:		texrend

# build use macOS Preview.app to display in a specified lcoation
.PHONY:		finalshow
finalshow:	texfinalshow

# like show, but no reposition
.PHONY:		open
open:		texopen
