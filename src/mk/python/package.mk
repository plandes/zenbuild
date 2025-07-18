#@meta {author: "Paul Landes"}
#@meta {desc: "wheel/global package build and install", date: "2025-06-22"}
#@meta {requires: "python/build.mk", order: "before"}


## Build
#
INFO_TARGETS +=		pypackageinfo


## Module
#
# derived
PY_PKG_PIP_BIN ?=	$(PY_PIP_BIN)

# distribution
PY_DIST_DIR ?=		$(MTARG)/dist
PY_WHEEL_FILE ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-$(PY_VERSION)-py3-none-any.whl
PY_CONDA_ENV_FILE ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-$(PY_VERSION)-environment.yml
PY_CONDA_GLOB ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-*.conda
PY_CONDA_FILE ?=	$(wildcard $(PY_CONDA_GLOB))
PY_GITIGNORE_ORG ?=	$(MTARG)/gitignore-old
PY_PKG_DEPS ?=		$(PY_WHEEL_FILE) $(PY_CONDA_ENV_FILE)
PY_PKG_BUILD_DEPS +=	$(PY_PYPROJECT_FILE)

# wheel (un)install hooks
PY_WH_INSTALL_DEPS +=
PY_WH_UNINSTALL_DEPS +=


# set to non-empty if the file hasn't been created
ifeq ($(strip $(PY_CONDA_FILE)),)
	PY_CONDA_FILE = force-target
endif


## Targets
#
.PHONY:			pypackageinfo
pypackageinfo:
			@echo "py_package_deps: $(PY_PKG_DEPS)"
			@echo "py_conda_file: $(PY_CONDA_FILE)"


## Shared environment install targets
#
$(PY_WHEEL_FILE):	$(PY_PKG_BUILD_DEPS)
			@echo "creating wheel file: $(PY_WHEEL_FILE)"
			@PX_DIST_DIR=$(PY_DIST_DIR) $(PY_PX_BIN) run build-wheel
.PHONY:			pywheel
pywheel:		$(PY_WHEEL_FILE)

# install the wheel in the shared environment
.PHONY:			pyinstallwheel
pyinstallwheel:		clean $(PY_WHEEL_FILE)
			$(PY_PKG_PIP_BIN) install $(PY_WHEEL_FILE)
.PHONY:			pyinstall
pyinstall:		pyinstallwheel $(PY_WH_INSTALL_DEPS)

# uninstall the wheel from the shared environment
.PHONY:			pyuninstallwheel
pyuninstallwheel:
			$(PY_PKG_PIP_BIN) uninstall -y $(PY_WHEEL_FILE)
.PHONY:			pyuninstall
pyuninstall:		pyuninstallwheel $(PY_WH_UNINSTALL_DEPS)

# reinstall the wheel
.PHONY:			pyreinstall
pyreinstall:
			@$(MAKE) $(PY_MAKE_ARGS) pyuninstall
			@$(MAKE) $(PY_MAKE_ARGS) pyinstall


## Package
#
# create the distribution files
# use a make subprocess to allow sub modules to add to PY_PKG_DEPS
.PHONY:			pypackage
pypackage:
			@$(MAKE) $(PY_MAKE_ARGS) $(PY_PKG_DEPS)

## Global install targets
#
# restore the original .gitignore file modified by the $(PY_CONDA_FILE) target
.PHONY:			pyrestoregitignore
pyrestoregitignore:
			@echo "replacing .gitignore"
			@[ -f $(PY_GITIGNORE_ORG) ] && \
				mv $(PY_GITIGNORE_ORG) .gitignore

# build the conda artifact (remove gitignore on pyproject.toml otherwise it
# goes missing from conda_build.sh during the pixi build)
$(PY_CONDA_FILE):	$(PY_PKG_BUILD_DEPS)
			$(PY_PX_BIN) lock
			@echo "copy original version of $(PY_GITIGNORE_ORG)"
			@mkdir -p $$(dirname $(PY_GITIGNORE_ORG))
			@cp .gitignore $(PY_GITIGNORE_ORG)
			@sed -i '/^\/pyproject.toml$$/d' .gitignore
			@PX_DIST_DIR=$(PY_DIST_DIR) $(PY_PX_BIN) run build-conda || \
				make pyrestoregitignore
			@$(MAKE) $(PY_MAKE_ARGS) pyrestoregitignore

# export environment.yml
$(PY_CONDA_ENV_FILE):	$(PY_PKG_BUILD_DEPS)
			@echo "creating conda env file $(PY_CONDA_ENV_FILE)..."
			@mkdir -p $(dir $(PY_CONDA_ENV_FILE))
			@$(PY_PX_BIN) workspace export \
				conda-environment > $(PY_CONDA_ENV_FILE)
			@echo "wrote: $(PY_CONDA_ENV_FILE)"
.PHONY:			pycondaenv
pycondaenv:		$(PY_CONDA_ENV_FILE)
