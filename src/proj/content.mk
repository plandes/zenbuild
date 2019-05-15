## makefile automates website files/documents

# the source repository directory that has content to copy to the site
CNT_SRC_STAGE_DIR ?=	$(CNT_STAGE_DIR)/$(CNT_SITE_DIR)/

## include content modules
include $(BUILD_MK_DIR)/content.mk


# package files in staging directory that has the generate site
.PHONY:			package
package:		cntsite

# make the locally site and direct a browser to it
.PHONY:			show
show:			package cntshow

# deploy the site to the webserver
.PHONY:			deploy
deploy:			cntdeploy

# deploy and direct a browser to the deployed site
.PHONY:			run
run:			cntrun
