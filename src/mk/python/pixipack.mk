#@meta {author: "Paul Landes"}
#@meta {desc: "create an enviornment file with pixi-pack", date: "2025-06-03"}
#@meta {requires: "python/build.mk", order: "before"}


## Build
#
INFO_TARGETS +=		pyppinfo
PY_PACKAGE_DEPS +=	$(PY_ENV_PP_FILE)


## Module
#
PY_PX_PACK_CACHE_DIR ?=	$(HOME)/.cache/pixi-pack
PY_PX_PACK_BIN ?=	pixi-pack
PY_ENV_PP_FILE ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-$(PY_VERSION)-environment.tar
PY_ENV_PP_EXT_DIR ?=	$(MTARG)/ppenv


## Targets
#
.PHOHY:			pyppinfo
pyppinfo:
			@echo "py_env_file: $(PY_ENV_PP_FILE)"


# extract the packed environment file into a temp dir
$(PY_ENV_PP_EXT_DIR):	$(PY_ENV_PP_FILE)
			@echo "creating dist file: $(PY_ENV_PP_EXT_DIR)..."
			@mkdir -p $(PY_ENV_PP_EXT_DIR)
			@tar xf $(PY_ENV_PP_FILE) -C $(PY_ENV_PP_EXT_DIR)

# build the conda packed environment file
$(PY_ENV_PP_FILE):	$(PY_CONDA_FILE)
			@echo "pixi packing $(PY_ENV_PP_FILE)..."
			@$(PY_PX_PACK_BIN) pack \
				--output-file $(PY_ENV_PP_FILE) \
				--inject $(PY_CONDA_GLOB) \
				--use-cache $(PY_PX_PACK_CACHE_DIR)
.PHONY:			pyppenvfile
pyppenvfile:		$(PY_ENV_PP_FILE)

# install in the global pixi environment
.PHONY:			pyppinstall
pyppinstall:		clean $(PY_ENV_PP_EXT_DIR)
			@echo "installing $(PY_PACKAGE_NAME)..."
			@$(PY_PX_BIN) global install $(PY_PACKAGE_NAME) \
				-c file://$(PY_ENV_PP_EXT_DIR)/channel \
				-c conda-forge --with pip && \
			$(PIXI_HOME)/envs/$(PY_PACKAGE_NAME)/bin/pip install \
				$(PY_ENV_PP_EXT_DIR)/pypi/*

# uninstall from the global pixi environment
.PHONY:			pyppuninstall
pyppuninstall:
			@echo "uninstalling $(PY_PACKAGE_NAME)..."
			@$(PY_PX_BIN) global uninstall $(PY_PACKAGE_NAME)

# reinstall into the global pixi environment
.PHONY:			pyppreinstall
pyppreinstall:
			@make $(PY_MAKE_ARGS) pyppuninstall || true
			@make $(PY_MAKE_ARGS) pyppinstall
