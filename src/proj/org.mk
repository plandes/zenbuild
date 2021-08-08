## makefile automates org mode files/documents

# tell org mode where to generate HTML files
OM_HTML_DIR ?=		$(MTARG)/site
# default show target for orgmode files
OM_BUILD_TARG ?=	orgmode-doc-html
OM_SHOW_TARG ?=		orgmode-doc-show
# tell content module to use org mode module to generate HTML files
CNT_DEP_TARGS +=	$(OM_BUILD_TARG)
# the source repository directory that has content to copy to the site
CNT_SITE_DIR ?=		./content
# content staging directory where all files copied before deploy
CNT_STAGE_DIR ?=	$(OM_HTML_DIR)/
# used for `orgmode-show'
OM_SHOW_FILES ?=	$(OM_HTML_DIR)/*.html

## include org mode and content modules
include $(BUILD_MK_DIR)/orgmode-doc.mk
include $(BUILD_MK_DIR)/content.mk


# package files in staging directory that has the generate site
.PHONY:			package
package:		cntsite

# make the locally site and direct a browser to it
.PHONY:			show
show:			package $(OM_SHOW_TARG)

# deploy the site to the webserver
.PHONY:			deploy
deploy:			cntdeploy

# deploy and direct a browser to the deployed site
.PHONY:			run
run:			cntrun
