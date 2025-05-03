#@meta {author: "Paul Landes"}
#@meta {desc: "build and deploy markdown -> html docs", date: "2025-04-27"}


## Includes
#
include $(BUILD_MK_DIR)/markdown.mk

# silence warnings on git.mk import
GIT_BUILD_INFO_BIN =	echo


## Targets
#
# force compile
.PHONY:			compile
compile:		markdown-force-compile

# package files in staging directory that has the generate site
.PHONY:			package
package:		markdown-package

# make the html version and direct a browser to it
.PHONY:			show
show:			markdown-show-html

# make the pdf version and direct a browser to it
.PHONY:			showpdf
showpdf:		markdown-show-pdf

.PHONY:			install
install:		markdown-install
