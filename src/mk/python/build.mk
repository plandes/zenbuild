#@meta {author: "Paul Landes"}
#@meta {desc: "pixi build automation module", date: "2025-04-17"}


## Build system
#
INFO_TARGETS +=		pyinfo
ADD_CLEAN +=		$(PY_PYPROJECT_FILE)
CLEAN_DEPS +=
CLEAN_ALL_DEPS +=	pyclean
VAPORIZE_DEPS +=	pyrmpixienv pyrmlockfile


## Module
#
# python programs
PY_PYTHON_BIN ?=	python
PY_PIP_BIN ?=		$(PY_PYTHON_BIN) -m pip
# pixi programs
PY_PX_BIN ?=		pixi
# homegrown
PY_RP_RELPO_BIN ?=	relpo
# make branch
PY_MAKE_ARGS ?=		--no-print-directory
# any dependency need by creating the pyproject.toml file
PY_PYPROJECT_DEPS +=
# clean
PY_CLEAN_DIRS +=	src resources

# paths
PY_RP_PROJ_FILES_DEF =	relpo.yml,zenbuild/src/relpo/template/build.yml
PY_RP_PROJ_FILES ?=	$(PY_RP_PROJ_FILES_DEF)
PY_RP_PROJ_FILES_ +=	$(subst ${space},${comma},$(PY_RP_PROJ_FILES))
PY_RP_PROJ_MAIN_FILE ?=	$(word 1,$(subst $(comma), ,$(PY_RP_PROJ_FILES_)))
PY_PYPROJECT_FILE ?=	pyproject.toml
PY_META_FILE ?=		$(MTARG)/build.json
PY_SRC_DIR ?=		src

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

PY_PACKAGE_NAME ?=	$(PY_DOMAIN_NAME)_$(PY_PROJECT_NAME)

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
			@echo "py_package_name: $(PY_PACKAGE_NAME)"
			@echo "py_version: $(PY_VERSION)"
			@echo "py_github_user: $(PY_GITHUB_USER)"

# dump a yaml version of the project metadata
.PHONY:			pyyamlmetafile
pyyamlmetafile:
			@$(call relpo,meta -f yaml)

# dump a json version of the project metadata
.PHONY:			pyjsonmetafile
pyjsonmetafile:
			@$(call relpo,meta -f json)

# project what is used as the (synthesized) relpo.yml config file
.PHONY:			pyrelpoconfig
pyrelpoconfig:
			@$(call relpo,config)

# use relpo to generate the pyproject.toml file used by pixi
$(PY_PYPROJECT_FILE):	$(PY_RP_PROJ_MAIN_FILE) $(PY_PYPROJECT_DEPS)
			@$(call loginfo,creating project file: $(PY_PYPROJECT_FILE))
			@mkdir -p $(dir $(PY_PYPROJECT_FILE))
			@$(call relpo,pyproject -o $(PY_PYPROJECT_FILE))
.PHONY:			pyproject
pyproject:		$(PY_PYPROJECT_FILE)

# pixi install loal environment
.PHONY:			pyinit
pyinit:			$(PY_PYPROJECT_FILE)
			$(PY_PX_BIN) install

# dependency tree
.PHONY:			pydeptree
pydeptree:		$(PY_PYPROJECT_FILE)
			@$(PY_PX_BIN) tree

# pip-only dependency tree with version descriptions
.PHONY:			pypipdeptree
pypipdeptree:		$(PY_PYPROJECT_FILE)
			$(eval pip := $(PY_PX_BIN) run python -m pip)
			$(eval has := $(shell $(pip) freeze | grep pipdeptree | wc -l))
			@[ "$(has)" == "0" ] && $(pip) install pipdeptree || true
			@$(PY_PX_BIN) run python -m pipdeptree


## Clean
#
# clean derived objects
.PHONY:			pyclean
pyclean:
			@for i in $(PY_CLEAN_DIRS) ; do \
				if [ -d $$i ] ; then \
					echo "removing: $${i}/__pycache__" ; \
					find . -type d -name __pycache__ \
						-prune -exec rm -r {} \; ; \
				fi ; \
			done

# also clean up the pixi environments and other temporary files
.PHONY:			pyrmpixienv
pyrmpixienv:
			@if [ -d .pixi ] ; then \
				echo "removing: pixi environments" ; \
				rm -fr .pixi ; \
			fi

# remove lock file
.PHONY:			pyrmlockfile
pyrmlockfile:
			@if [ -f pixi.lock ] ; then \
				echo "removing: pixi lock file" ; \
				rm pixi.lock ; \
			fi
