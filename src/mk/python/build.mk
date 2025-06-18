#@meta {author: "Paul Landes"}
#@meta {desc: "pixi build automation module", date: "2025-04-17"}


## Build system
#
INFO_TARGETS +=		pyinfo
PY_TEST_ALL_TARGETS +=
ADD_CLEAN +=		$(PY_PYPROJECT_FILE)
CLEAN_DEPS +=		pyclean
CLEAN_ALL_DEPS +=	pycleanall
VAPORIZE_DEPS +=	pyvaporize


## Module
#
# python programs
PY_PYTHON_BIN ?=	python
PY_PIP_BIN ?=		$(PY_PYTHON_BIN) -m pip
# pixi programs
PY_PX_BIN ?=		pixi
# test file glob pattern
PY_TEST_GLOB ?=		test_*.py
# homegrown
PY_RP_RELPO_BIN ?=	relpo
# the entry point prototyping script
PY_HARNESS_BIN ?=	harness.py
# make branch
PY_MAKE_ARGS ?=		--no-print-directory

# paths
PY_RP_PROJ_FILES_DEF =	relpo.yml,zenbuild/src/relpo/template/build.yml
PY_RP_PROJ_FILES ?=	$(PY_RP_PROJ_FILES_DEF)
PY_RP_PROJ_FILES_ +=	$(subst ${space},${comma},$(PY_RP_PROJ_FILES))
PY_RP_PROJ_MAIN_FILE ?=	$(word 1,$(subst $(comma), ,$(PY_RP_PROJ_FILES_)))
PY_PYPROJECT_FILE ?=	pyproject.toml
PY_META_FILE ?=		$(MTARG)/build.json
PY_SRC_DIR ?=		src
PY_TEST_DIR ?=		tests

# set the package name and verion if not already (relpo program set this)
ifdef PY_DOMAIN_NAME
ifeq ($(BUILD_DEBUG),1)
$(info already set:)
$(info PY_PACKAGE_NAME=$(PY_PACKAGE_NAME))
$(info PY_VERSION=$(PY_PACKAGE_NAME))
endif
else
py_template = {{ config.project.domain }} $\
	      {{ config.project.name }} $\
	      {{ config.github.user }} $\
	      {{ project.change_log.entries[-1].version.simple }}
py_rendered := $(shell echo $(py_template) | \
	$(PY_RP_RELPO_BIN) template --tmp $(MTARG) -c $(PY_RP_PROJ_FILES_))
PY_DOMAIN_NAME := $(word 1,$(py_rendered))
PY_PROJECT_NAME := $(word 2,$(py_rendered))
PY_GITHUB_USER := $(word 3,$(py_rendered))
PY_VERSION := $(word 4,$(py_rendered))
ifeq ($(BUILD_DEBUG),1)
$(info package name: $(PY_PACKAGE_NAME))
endif
endif

# distribution
PY_PACKAGE_NAME ?=	$(PY_DOMAIN_NAME)_$(PY_PROJECT_NAME)
PY_DIST_DIR ?=		$(MTARG)/dist
PY_WHEEL_FILE ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-$(PY_VERSION)-py3-none-any.whl
PY_CONDA_ENV_FILE ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-$(PY_VERSION)-environment.yml
PY_CONDA_GLOB ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-*.conda
PY_CONDA_FILE ?=	$(wildcard $(PY_CONDA_GLOB))
PY_GITIGNORE_ORG ?=	$(MTARG)/gitignore-old
PY_PACKAGE_DEPS ?=	$(PY_WHEEL_FILE) $(PY_CONDA_ENV_FILE)

# set to non-empty if the file hasn't been created
ifeq ($(strip $(PY_CONDA_FILE)),)
	PY_CONDA_FILE = force-target
endif

# relpo function used in targets to automate pixi
define relpo
	$(PY_RP_RELPO_BIN) $(1) \
		--tmp $(MTARG) \
		--config $(PY_RP_PROJ_FILES_) $(2)
endef


## Targets
#
# print info
.PHONY:			pyinfo
pyinfo:
			@echo "py_rp_proj_files: $(PY_RP_PROJ_FILES_)"
			@echo "py_rp_proj_main_file: $(PY_RP_PROJ_MAIN_FILE)"
			@echo "py_pyproject_file: $(PY_PYPROJECT_FILE)"
			@echo "py_package_deps: $(PY_PACKAGE_DEPS)"
			@echo "py_package_name: $(PY_PACKAGE_NAME)"
			@echo "py_version: $(PY_VERSION)"
			@echo "py_conda_file: $(PY_CONDA_FILE)"
			@echo "py_github_user: $(PY_GITHUB_USER)"

# dump a yaml version of the project metadata
.PHONY:			pyyamlmetafile
pyyamlmetafile:
			@$(call relpo,meta -f yaml)

# project what is used as the (synthesized) relpo.yml config file
.PHONY:			pyrelpoconfig
pyrelpoconfig:
			@$(call relpo,config)

# use relpo to generate the pyproject.toml file used by pixi
$(PY_PYPROJECT_FILE):	$(PY_RP_PROJ_MAIN_FILE)
			@echo "creating project file: $(PY_PYPROJECT_FILE)"
			@mkdir -p $(dir $(PY_PYPROJECT_FILE))
			@$(call relpo,pyproject -o $(PY_PYPROJECT_FILE))
.PHONY:			pyproject
pyproject:		$(PY_PYPROJECT_FILE)

# pixi install loal environment
.PHONY:			pyinit
pyinit:			$(PY_PYPROJECT_FILE)
			$(PY_PX_BIN) install

# run unit tests
.PHONY:			pytestprev
pytestprev:		$(PY_PYPROJECT_FILE)
			$(PY_PX_BIN) run testprev ''$(PY_TEST_GLOB)''

.PHONY:			pytestcur
pytestcur:		$(PY_PYPROJECT_FILE)
			$(PY_PX_BIN) run testcur ''$(PY_TEST_GLOB)''

.PHONY:			pytest
pytest:			pytestprev pytestcur


## Shared environment install targets
#
$(PY_WHEEL_FILE):	$(PY_PYPROJECT_FILE)
			@echo "creating wheel file: $(PY_WHEEL_FILE)"
			@PX_DIST_DIR=$(PY_DIST_DIR) $(PY_PX_BIN) run build-wheel
.PHONY:			pywheel
pywheel:		$(PY_WHEEL_FILE)

# install the wheel in the shared environment
.PHONY:			pyinstall
pyinstall:		clean $(PY_WHEEL_FILE)
			$(PY_PIP_BIN) install $(PY_WHEEL_FILE)

# uninstall the wheel from the shared environment
.PHONY:			pyuninstall
pyuninstall:
			$(PY_PIP_BIN) uninstall -y $(PY_WHEEL_FILE)

# reinstall the wheel
.PHONY:			pyreinstall
pyreinstall:
			@make pyuninstall
			@make pyinstall


## Package
#
# create the distribution files
# use a make subprocess to allow sub modules to add to PY_PACKAGE_DEPS
.PHONY:			pypackage
pypackage:
			@make $(PY_MAKE_ARGS) $(PY_PACKAGE_DEPS)

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
$(PY_CONDA_FILE):	$(PY_PYPROJECT_FILE)
			$(PY_PX_BIN) lock
			@echo "copy original version of $(PY_GITIGNORE_ORG)"
			@mkdir -p $$(dirname $(PY_GITIGNORE_ORG))
			@cp .gitignore $(PY_GITIGNORE_ORG)
			@sed -i '/^\/pyproject.toml$$/d' .gitignore
			@PX_DIST_DIR=$(PY_DIST_DIR) $(PY_PX_BIN) run build-conda || \
				make pyrestoregitignore
			@make $(PY_MAKE_ARGS) pyrestoregitignore

# export environment.yml
$(PY_CONDA_ENV_FILE):	$(PY_PYPROJECT_FILE)
			@echo "creating conda env file $(PY_CONDA_ENV_FILE)..."
			@mkdir -p $(dir $(PY_CONDA_ENV_FILE))
			@$(PY_PX_BIN) workspace export \
				conda-environment > $(PY_CONDA_ENV_FILE)
			@echo "wrote: $(PY_CONDA_ENV_FILE)"
.PHONY:			pycondaenv
pycondaenv:		$(PY_CONDA_ENV_FILE)


## Command line and source control
#
# run a command via Pixi using the ApplicationFactory class
.PHONY:			pyinvoke
pyinvoke:		$(PY_PYPROJECT_FILE)
			@if [ -z "$(ARG)" ] ; then \
				echo "warning: use:\nmake ARG='[arguments]' pyinvoke" ; \
			fi
			@$(PY_PX_BIN) run $(PY_INVOKE_ARG) invoke '$(PY_PROJECT_NAME) $(ARG)'

# run a command through the harness
.PHONY:			pyharn
pyharn:			$(PY_PYPROJECT_FILE)
			@if [ -z "$(ARG)" ] ; then \
				echo "warning: use:\nmake ARG='[arguments]' run" ; \
			fi
			@PYTHONPATH="$${PYTHONPATH:+$${PYTHONPATH}:}src" \
				$(PY_PX_BIN) run $(PY_INVOKE_ARG) \
				python $(PY_HARNESS_BIN) $(ARG)

# print help
.PHONY:			pyhelp
pyhelp:			$(PY_PYPROJECT_FILE)
			@make $(PY_MAKE_ARGS) ARG="--help" pyinvoke

# dependency tree
.PHONY:			pydeptree
pydeptree:		$(PY_PYPROJECT_FILE)
			@$(PY_PX_BIN) tree

# make a tag using the version of the last commit
.PHONY:			pymktag
pymktag:
			@if [ -z "$(COMMENT)" ] ; then \
				echo "use:\nmake COMMENT='comment' pymktag" ; \
				exit 1 ; \
			fi
			@$(call relpo,mktag,"--message=$(COMMENT)")

# remove the last tag
.PHONY:			pyrmtag
pyrmtag:
			@$(call relpo,rmtag,"--message=$(COMMENT)")



# delete the last tag and create a new one on the latest commit
.PHONY:			pybumptag
pybumptag:
			@$(call relpo,bumptag)

# print this repo's info
.PHONY:			pycheck
pycheck:		$(PY_PYPROJECT_FILE)
			@$(PY_PX_BIN) lock
			@$(call relpo,check) || true

# generate site documentation
.PHONY:			pydoc
pydoc:
			@echo "generating project documentation..."
			@$(call relpo,doc)


## Clean
#
# clean derived objects
.PHONY:			pyclean
pyclean:
			@echo "removing: __pycache__"
			@find . -type d -name __pycache__ -prune -exec rm -r {} \;
			@if [ -d tests ] ; then \
				find tests -type d -name __pycache__ -prune -exec rm -r {} \; ; \
			fi

# also clean up the pixi environments and other temporary files
.PHONY:			pycleanall
pycleanall:
			@if [ -d .pixi ] ; then \
				echo "removing: pixi environments" ; \
				rm -fr .pixi ; \
			fi

# remove lock file
.PHONY:			pyvaporize
pyvaporize:
			@if [ -f pixi.lock ] ; then \
				echo "removing: pixi lock file" ; \
				rm pixi.lock ; \
			fi

# run unit and integration tests
.PHONY:			pytestall
pytestall:		pytest $(PY_TEST_ALL_TARGETS)
