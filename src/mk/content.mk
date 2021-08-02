## make include file for content distribution projects
## PL 12/08/2018

# URL to deploy content
CNT_DOC_URL ?=		https://example.com/webdavroot
# if provided, the mount is skipped if the directory is found
CNT_MOUNT_CHECK_DIR ?=
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
# additional dependencies to build before copying the site
CNT_DEP_TARGS +=
# additional dependencies to build after copying the site
CNT_DEPLOY_DEP_TARGS +=
# the URL to point the browser on a make remote show
CNT_DEPLOY_URL ?=	https://example.com/site/index.html
# default show target to show
CNT_SHOW_TARG ?=	cntshowremote
# default rsync options: stage and deploy respectively
CNT_RSYNC_OPTS ?=	-auv
CNT_RSYNC_DEP_OPTS ?=	$(CNT_RSYNC_OPTS) --copy-links --delete $(CNT_SRC_STAGE_DIR)

# module config
INFO_TARGETS +=		cntinfo


# info
.PHONY:			cntinfo
cntinfo:
			@echo "cnt-doc-url: $(CNT_DOC_URL)"
			@echo "cnt-site-dir: $(CNT_SITE_DIR)"
			@echo "cnt-stage-dir: $(CNT_STAGE_DIR)"
			@echo "cnt-content-dir: $(CNT_CONTENT_DIR)"
			@echo "cnt-inst-dir: $(CNT_INST_DIR)"
			@echo "cnt-dep-targs: $(CNT_DEP_TARGS)"
			@echo "cnt-deploy-url: $(CNT_DEPLOY_URL)"


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
				echo "copying $(CNT_SITE_DIR) -> $(CNT_STAGE_DIR)" ; \
				if [ ! -e $$i ] ; then \
					echo "warning: missing path $$i--skipping..." ; \
				else \
					rsync $(CNT_RSYNC_OPTS) --exclude .DS_Store $$i $(CNT_STAGE_DIR) || true ; \
				fi ; \
			done

.PHONY:			cntsite
cntsite:		$(CNT_DEP_TARGS) cntcopysite $(CNT_DEPLOY_DEP_TARGS)

# mount the volume on OSX in order to copy
.PHONY:			cntmount
cntmount:
			@if [ -z "$(CNT_DOC_URL)" ] ; then \
				echo "CNT_DOC_URL not set, skipping mount" ; \
			else \
				echo "checking $(CNT_MOUNT_CHECK_DIR)" ; \
				if [ ! -z "$(CNT_MOUNT_CHECK_DIR)" -a -d "$(CNT_MOUNT_CHECK_DIR)" ] ; then \
					echo "already mounted: $(CNT_MOUNT_CHECK_DIR)" ; \
				else \
					echo "mounting $(CNT_DOC_URL)..." ; \
					osascript -e 'tell application "Finder" to mount volume "$(CNT_DOC_URL)"' ; \
				fi \
			fi

# generate the site and copy as dry run for the rsync copy
.PHONY:			cntdeploydry
cntdeploydry:		cntmount cntsite
			rsync $(CNT_RSYNC_DEP_OPTS) -n $(CNT_INST_DIR) || true


# generate the site and copy it to the mounted volume that has the destination
.PHONY:			cntdeploy
cntdeploy:		cntmount cntsite
			@if [ -z "$(CNT_INST_DIR)" ] ; then \
				echo "no install directory defined" ; \
				exit 1 ; \
			fi
			rsync $(CNT_RSYNC_DEP_OPTS) $(CNT_INST_DIR) || true

.PHONY:			cntshow
cntshow:		$(CNT_SHOW_TARG)

# create, deploy the site, then browse to it
.PHONY:			cntshowremote
cntshowremote:		cntdeploy
			open $(CNT_DEPLOY_URL)
			osascript -e 'tell application "Emacs" to activate'

# reload the browser (useful for deployed/remote Javascript debugging)
.PHONY:			cntreload
cntreload:
			@echo "reloading..."
			osascript src/as/reload-events.scpt
