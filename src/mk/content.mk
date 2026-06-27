## @meta {author: "Paul Landes"}
## @meta {desc: "content distribution projects", date: "12/08/2018"}


# where source static content lives
CNT_SITE_DIR ?=		./site
# objects to build during site package
CNT_SITE_OBJS +=	$(CNT_SITE_DIR)
# site build directory on package
CNT_STAGE_DIR ?=	$(MTARG)
# directory on the host to deploy (used as target with rsync)
CNT_INST_DIR ?=		
# source directory to use for copy with rsync
CNT_SRC_STAGE_DIR ?=	$(CNT_STAGE_DIR)
# where the site content lives (used by orgmode builds)
CNT_CONTENT_DIR ?=	$(abspath $(CNT_STAGE_DIR)/$(CNT_SITE_DIR))
# the path on the remote to rsync to
CNT_DEPLOY_PATH ?=	$(CNT_SITE_NAME)
# additional dependencies to build before copying the site
CNT_DEP_TARGS +=
# additional dependencies to build after copying the site
CNT_DEPLOY_DEP_TARGS +=
# command used to deploy: takes stage dir, remote leaf path, extra args
CNT_DEPLOY_CMD ?=	printf "error: CNT_DEPLOY_CMD not set--can not deploy\n"
# same, but adds option for dry run
CNT_DEPLOY_DRY_CMD ?=	printf "error: CNT_DEPLOY_DRY_CMD not set--can not deploy\n"
# module config
INFO_TARGETS +=		cntinfo


# info
.PHONY:			cntinfo
cntinfo:
			@echo "cnt-site-dir: $(CNT_SITE_DIR)"
			@echo "cnt-stage-dir: $(CNT_STAGE_DIR)"
			@echo "cnt-content-dir: $(CNT_CONTENT_DIR)"
			@echo "cnt-inst-dir: $(CNT_INST_DIR)"
			@echo "cnt-dep-targs: $(CNT_DEP_TARGS)"


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
					rsync $(CNT_RSYNC_OPTS) --exclude .DS_Store $$i $(CNT_STAGE_DIR) || true ; \
				fi ; \
			done

# create the site and copy it
.PHONY:			cntsite
cntsite:		$(CNT_DEP_TARGS) cntcopysite $(CNT_DEPLOY_DEP_TARGS)

# generate the site and copy as dry run for the rsync copy
.PHONY:			cntdeploydry
cntdeploydry:		cntsite
			@$(CNT_DEPLOY_DRY_CMD) $(CNT_STAGE_DIR) $(CNT_DEPLOY_PATH)

# generate the site and copy it to the remove that has the destination
.PHONY:			cntdeploy
cntdeploy:		cntsite
			@$(CNT_DEPLOY_CMD) $(CNT_STAGE_DIR) $(CNT_DEPLOY_PATH)
