## make include file for deploy Python documentation locally
## PL 11/20/2020

## module build

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
# this is where the files will be rsynch to
CNT_INST_DIR ?=		$(CNT_MNT_DIR)/$(CNT_SITE_ROOT)/$(PY_DOC_DPLY_PATH)apidoc


## python build

# location of the document metadata creation script
PY_DOC_DOC_META_PATH ?=	$(BUILD_BIN_DIR)/docmeta.py
# the path on the mounted volume path (CNT_INST_DIR) to rsync to
PY_DOC_DPLY_PATH ?=	$(CNT_SITE_NAME)
# constructed metadata info file from build.json
PY_DOC_META_INFO ?=	$(CNT_INST_DIR)/meta.json
#
PY_DOC_CONF_ASUPS +=	-u $(ZENBUILD_DOC_SERVER)


## build

# because of the syntax of make to rsync command, we have to rename to the
# destination directory, which is the name of the project
CNT_DEPLOY_DEP_TARGS +=	pydocdeploymv

# module config
INFO_TARGETS +=		pydocdeployinfo

ifneq ($(ZENBUILD_DOC_USER),)
PY_DOC_CONF_ASUPS += -a $(ZENBUILD_DOC_USER)
endif


## includes
include $(BUILD_MK_DIR)/content.mk


## targets
.PHONY:			pydocdeployinfo
pydocdeployinfo:
			@echo "cnt-mount-check-dir: $(CNT_MOUNT_CHECK_DIR)"
			@echo "cnt-deploy-path: $(PY_DOC_DPLY_PATH)"

.PHONY:			pydocdeploysrc
pydocdeploysrc:
			make PY_DOC_CONF_ARGS_SUP="$(PY_DOC_CONF_ASUPS)" pydocsrc

.PHONY:			pydocdeployhtml
pydocdeployhtml:
			make PY_DOC_CONF_ARGS_SUP="$(PY_DOC_CONF_ASUPS)" pydochtml

.PHONY:			pydocdeploy
pydocdeploy:		pydocdeployhtml cntdeploy

.PHONY:			pydocdeploymv
pydocdeploymv:
			@echo copying stage to $(CNT_SRC_STAGE_DIR)
			@if [ -d "$(CNT_SRC_STAGE_DIR)" ] ; then \
				rm -r $(CNT_SRC_STAGE_DIR) ; \
			fi
			mv $(CNT_STAGE_DIR)/html $(CNT_SRC_STAGE_DIR)
			@echo creating API docs metadata
			$(PY_DOC_DOC_META_PATH) $(GIT_BUILD_INFO) $(PY_DOC_META_INFO)
