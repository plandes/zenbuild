#@meta {author: "Paul Landes"}
#@meta {desc: "website files and documents", date: "2025-04-28"}


## Module
#
# the source repository directory that has content to copy to the site
CNT_SRC_STAGE_DIR ?=	$(CNT_CONTENT_DIR)/


## Include
#
include $(BUILD_MK_DIR)/content.mk


## Targets
#
# package files in staging directory that has the generate site
.PHONY:			package
package:		cntsite

# make the locally site and direct a browser to it
.PHONY:			show
show:			package cntshow

# deploy the site to the webserver
.PHONY:			deploy
deploy:			cntdeploy

# longer, but safer deploy to the server
.PHONY:			redeploy
redeploy:		clean cntdeploy

# deploy to an secondary (external) site
.PHONY:			externalsite
externalsite:		cntextdeploy

# deploy and direct a browser to the deployed site
.PHONY:			run
run:			cntrun
