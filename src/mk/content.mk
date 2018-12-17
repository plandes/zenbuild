## make include file for content distribution projects
## PL 12/08/2018

CNT_DOC_URL ?=		https://example.com/webdavroot
CNT_SITE_DIR ?=		./site
CNT_STAGE_DIR ?=	$(MTARG)
CNT_INST_DIR ?=		
CNT_DEP_TARGS +=
CNT_DEPLOY_URL ?=	https://example.com/site/index.html

# module config
INFO_TARGETS +=		cntinfo


# info
.PHONY:			cntinfo
cntinfo:
			@echo "cnt-doc-url: $(CNT_DOC_URL)"
			@echo "cnt-site-dir: $(CNT_SITE_DIR)"
			@echo "cnt-stage-dir: $(CNT_STAGE_DIR)"
			@echo "cnt-inst-dir: $(CNT_INST_DIR)"
			@echo "cnt-dep-targs: $(CNT_DEP_TARGS)"
			@echo "cnt-deploy-url: $(CNT_DEPLOY_URL)"


# generate the content site by making the target dir and copying contents
.PHONY:			cntsite
cntsite:		$(CNT_DEP_TARGS)
			@if [ ! -d "$(CNT_STAGE_DIR)" ] ; then \
				mkdir -pv $(CNT_STAGE_DIR) ; \
			fi
			cp -rRL $(CNT_SITE_DIR) $(CNT_STAGE_DIR)

# mount the volume on OSX in order to copy
.PHONY:			cntmount
cntmount:
			osascript -e 'tell application "Finder" to mount volume "$(CNT_DOC_URL)"'

# generate the site and copy as dry run for the rsync copy
.PHONY:			cntdeploydry
cntdeploydry:		cntmount $(CNT_DEP_TARGS)
			rsync -rltpgoDuv -n --delete $(CNT_STAGE_DIR) $(CNT_INST_DIR) || true


# generate the site and copy it to the mounted volume that has the destination
.PHONY:			cntdeploy
cntdeploy:		cntsite cntmount
			@if [ -z "$(CNT_INST_DIR)" ] ; then \
				echo "no install directory defined" ; \
				exit 1 ; \
			fi
			rsync -rltpgoDuv --delete $(CNT_STAGE_DIR) $(CNT_INST_DIR) || true

# create, deploy the site, then browse to it
.PHONY:			cntrun
cntrun:			cntdeploy
			open $(CNT_DEPLOY_URL)
			osascript -e 'tell application "Emacs" to activate'

# reload the browser (useful for deployed/remote Javascript debugging)
.PHONY:			cntreload
cntreload:
			@echo "reloading..."
			osascript src/as/reload-events.scpt
