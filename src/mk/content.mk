## make include file for content distribution projects
## PL 12/08/2018

CNT_DOC_URL ?=		https://example.com/webdavroot
CNT_SRC_DIR ?=		$(MTARG)
CNT_INST_DIR ?=		/tmp/some/install/path
CNT_DEP_TARGS +=
CNT_DEPLOY_URL ?=	https://example.com/site/index.html


.PHONY:			cntmount
cntmount:
			osascript -e 'tell application "Finder" to mount volume "$(CNT_DOC_URL)"'

.PHONY:			cntdeploy
cntdeploy:		cntmount $(CNT_DEP_TARGS)
			rsync -rltpgoDuv --delete $(CNT_SRC_DIR) $(CNT_INST_DIR) || true

.PHONY:			cntdeploydry
cntdeploydry:		cntmount $(CNT_DEP_TARGS)
			rsync -rltpgoDuv -n --delete $(CNT_SRC_DIR) $(CNT_INST_DIR) || true

.PHONY:			cntrun
cntrun:			cntdeploy
			open $(CNT_DEPLOY_URL)
			osascript -e 'tell application "Emacs" to activate'

.PHONY:			cntreload
cntreload:
			@echo "reloading..."
			osascript src/as/reload-events.scpt
