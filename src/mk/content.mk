## @meta {author: "Paul Landes"}
## @meta {desc: "content distribution projects", date: "12/08/2018"}


# this must be set in the makefile
CNT_SITE_NAME ?=	undefined
# where source static content lives
CNT_SITE_DIR ?=		./site
# objects to build during site package
CNT_SITE_OBJS +=	$(CNT_SITE_DIR)
# site build directory on package
CNT_STAGE_DIR ?=	$(MTARG)
# remote prefix (root-based)
CNT_DEPLOY_PRE_DIR ?=	
# the path on the remote to rsync to
slash-join =		$(if $(strip $(1)),$(1)/$(2),$(2))
CNT_DEPLOY_DIR ?=	$(call slash-join,$(CNT_DEPLOY_PRE_DIR),$(CNT_SITE_NAME))
#
CNT_DEPLOY_LOC_DIR ?=	$(CNT_STAGE_DIR)
# additional dependencies to build before copying the site
CNT_DEP_TARGS +=
# additional dependencies to build after copying the site
CNT_DEPLOY_DEP_TARGS +=
# default rsync options for local staging directory
CNT_RSYNC_LOCAL_OPTS ?=	-auv --copy-links
# command used to deploy: takes stage dir, remote leaf path, extra args
CNT_DEPLOY_CMD ?=	printf "error: CNT_DEPLOY_CMD not set--can not deploy\n"
# same, but adds option for dry run
CNT_DEPLOY_DRY_CMD ?=	printf "error: CNT_DEPLOY_DRY_CMD not set--can not deploy\n"
# used for rendring local generated site
CNT_HTML_FILE ?=	index.html
CNT_LOCAL_HTML_FILE ?=	$(abspath $(CNT_STAGE_DIR)/$(CNT_SITE_DIR)/$(CNT_HTML_FILE))
# module config
INFO_TARGETS +=		cntinfo


# info
.PHONY:			cntinfo
cntinfo:
			@echo "cnt-site-dir: $(CNT_SITE_DIR)"
			@echo "cnt-stage-dir: $(CNT_STAGE_DIR)"
			@echo "cnt-dep-targs: $(CNT_DEP_TARGS)"
			@echo "cnt-deploy-path: $(CNT_DEPLOY_DIR)"


# generate the content site by making the target dir and copying contents
.PHONY:			cntcopysite
cntcopysite:
			@if [ ! -d "$(CNT_STAGE_DIR)" ] ; then \
				mkdir -pv $(CNT_STAGE_DIR) ; \
			fi
			@if [ -d "$(CNT_SITE_DIR)" ] ; then \
				mkdir -pv $(CNT_SITE_DIR) ; \
			fi
			@for i in $(CNT_SITE_OBJS) ; do \
				if [ -e $$i ] ; then \
					echo "copying $(CNT_SITE_DIR) -> $(CNT_STAGE_DIR)" ; \
					rsync $(CNT_RSYNC_LOCAL_OPTS) --exclude .DS_Store $$i $(CNT_STAGE_DIR) || true ; \
				fi ; \
			done

# create the site and copy it
.PHONY:			cntsite
cntsite:		$(CNT_DEP_TARGS) cntcopysite $(CNT_DEPLOY_DEP_TARGS)

# generate the site and copy as dry run for the rsync copy
.PHONY:			cntdeploydry
cntdeploydry:		cntsite
			@$(CNT_DEPLOY_DRY_CMD) $(CNT_DEPLOY_LOC_DIR) $(CNT_DEPLOY_DIR)

# generate the site and copy it to the remove that has the destination
.PHONY:			cntdeploy
cntdeploy:		cntsite
			@$(CNT_DEPLOY_CMD) $(CNT_DEPLOY_LOC_DIR) $(CNT_DEPLOY_DIR)

# display the local built site
.PHONY:			cntshow
cntshow:		cntsite
			@$(RENDER_BIN) $(CNT_LOCAL_HTML_FILE)
