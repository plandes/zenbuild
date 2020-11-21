## make include file for deploy Python documentation locally
## PL 11/20/2020

## python doc
# if provided, the mount is skipped if the directory is found
CNT_MOUNT_CHECK_DIR ?=	$(CNT_INST_DIR)/$(GIT_PROJ)
# the generated documentation directory
CNT_SITE_DIR ?= 	$(GIT_DOC_SRC_DIR)
# site build directory on package
CNT_STAGE_DIR ?= 	$(PY_DOC_DIR)/stage
# this will be mounted via webdav
CNT_DOC_URL ?=		$(CNT_SITE_SERV)/$(CNT_SITE_ROOT)
# source directory to use for copy with rsync
CNT_SRC_STAGE_DIR ?=	$(CNT_STAGE_DIR)/$(GIT_PROJ)
# the path on the mounted volume path (CNT_INST_DIR) to rsync to
CNT_DEPLOY_PATH ?=	$(CNT_SITE_NAME)
# this is where the files will be rsynch to
CNT_INST_DIR ?=		$(CNT_MNT_DIR)/$(CNT_SITE_ROOT)/$(CNT_DEPLOY_PATH)apidoc

# because of the syntax of make to rsync command, we have to rename to the
# destination directory, which is the name of the project
CNT_DEPLOY_DEP_TARGS +=	pydocdeploymv

# module config
INFO_TARGETS +=		pydocdeployinfo

## includes
include $(BUILD_MK_DIR)/content.mk


.PHONY:			pydocdeployinfo
pydocdeployinfo:
			@echo "cnt-mount-check-dir: $(CNT_MOUNT_CHECK_DIR)"
			@echo "cnt-deploy-path: $(CNT_DEPLOY_PATH)"


.PHONY:			pydocdeploy
pydocdeploy:		pydochtml cntdeploy
			@echo rsync -auv -n --delete $(CNT_SRC_STAGE_DIR) $(CNT_INST_DIR)

.PHONY:			pydocdeploymv
pydocdeploymv:
			@if [ -d "$(CNT_SRC_STAGE_DIR)" ] ; then \
				rm -r $(CNT_SRC_STAGE_DIR) ; \
			fi
			mv $(CNT_STAGE_DIR)/html $(CNT_SRC_STAGE_DIR)
