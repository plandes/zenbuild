# make include file for Python projects
## PL 7/20/2018

## config

# python
PYTHON_BIN ?=		python
PYTHON_TEST_ARGS ?=	
PYTHON_TEST_ENV ?=
PIP_BIN ?=		$(PYTHON_BIN) -m pip
PIP_ARGS +=

# dependencies
PY_DEP_PRE_DEPS +=
PY_DEP_POST_DEPS +=

# python path
PY_SRC ?=		src/python
PY_SRC_TEST ?=		test/python
PY_SRC_TEST_PAT ?=	'test_*.py'
PY_TEST_DEPS +=
PY_TEST_POST_DEPS +=
PY_COMPILED +=		$(shell find $(PY_SRC) -name \*.pyc -type f)
PY_FLYMAKE +=		$(shell find $(PY_SRC) -name \*_flymake.py -type f)
PY_CACHE +=		$(shell find $(PY_SRC) $(PY_SRC_TEST) -type d -name __pycache__)
PY_RESOURCES +=		resources

# target
MTARG_PYDIST_DIR ?=	$(MTARG)/pydist
MTARG_PYDIST_BDIR ?=	$(MTARG_PYDIST_DIR)/build
MTARG_PYDIST_RES ?=	$(MTARG_PYDIST_BDIR)/resources
MTARG_PYDIST_ATFC ?=	$(MTARG_PYDIST_BDIR)/dist
MTARG_WHEEL_DIR ?=	$(MTARG)/wheel

# deploy
PYPI_TEST_NAME ?=	pypitest
PYPI_NON_TEST_NAME ?=	pypi
PYPI_USER ?=		pypiuser
PYPI_SIGN ?=		pypiuser@example.com

# build
ADD_CLEAN +=		$(PY_COMPILED) $(PY_CACHE)
ADD_CLEAN_ALL +=	$(PY_FLYMAKE)
INFO_TARGETS +=		pyinfo


# targets
.PHONY:			pyinfo
pyinfo:
			@echo "interpreter: $(PYTHON_BIN)"
			@echo "py-src: $(PY_SRC)"
			@echo "py-test: $(PY_SRC_TEST)"
			@echo "py-test-test-pat: $(PY_SRC_TEST_PAT)"
			@echo "py-dist-atfc: $(MTARG_PYDIST_ATFC)"
			@echo "py-dist-res: $(MTARG_PYDIST_RES)"

# build
$(MTARG_PYDIST_BDIR):
			@echo "building dist in $(MTARG_PYDIST_BDIR)"
			mkdir -p $(MTARG_PYDIST_BDIR)
			cp -r $(PY_SRC)/* $(MTARG_PYDIST_BDIR)
			@for i in $(PY_RESOURCES) ; do \
			    if [ -e $$i ] ; then \
			        mkdir -p $(MTARG_PYDIST_RES) ; \
				echo "copying resource $$i -> $(MTARG_PYDIST_RES)" ; \
				cp -r $$i $(MTARG_PYDIST_RES) ; \
			    fi ; \
			done
			[ -f README.md ] && cp README.md $(MTARG_PYDIST_BDIR) || true
			[ -f LICENSE ] && cp LICENSE $(MTARG_PYDIST_BDIR)/LICENSE.txt || true
			find $(MTARG_PYDIST_BDIR) -name \*_flymake.py -exec rm {} \;

# dry run for pip install
.PHONY:			pydeppeek
pydeppeek:
			pip-sync --dry-run $(PY_SRC)/requirements.txt || true

# install deps
.PHONY:			pydepsreqs
pydepsreqs:
			$(PIP_BIN) install $(PIP_ARGS) -r $(PY_SRC)/requirements.txt

# install python dependency packages
.PHONY:			pydeps
pydeps:			$(PY_DEP_PRE_DEPS) pydepsreqs $(PY_DEP_POST_DEPS)

# find inconsistent dependencies
.PHONY:			pydepcheck
pydepcheck:
			$(PIP_BIN) check

# show a dependency tree (inclusion of PROJ_MODULES=git needed)
.PHONY:			pydeptree
pydeptree:
			$(PYTHON_BIN) -m pipdeptree

# show conflicts in dependencies
.PHONY:			pydoctor
pydoctor:
			$(PYTHON_BIN) -m pip check

# execute python tests
.PHONY:			pytestunit
pytestunit:
			@echo "test: $(PY_SRC_TEST)"
			@echo "version: `$(PYTHON_BIN) --version`"
			@echo "args: -s $(PY_SRC_TEST) -p $(PY_SRC_TEST_PAT)"
			@if [ -d "$(PY_SRC_TEST)" ] ; then \
				PYTHONPATH=$(PY_SRC):$(PY_SRC_TEST) $(PYTHON_TEST_ENV) \
					$(PYTHON_BIN) $(PYTHON_TEST_ARGS) -m unittest discover \
					-s $(PY_SRC_TEST) -p $(PY_SRC_TEST_PAT) -v ; \
			fi
# execute all tests (i.e. integration)
.PHONY:			pytest
pytest:			$(TEST_DEPS) pytestunit $(PY_TEST_POST_DEPS)

# execute tests in a virtual environment
.PHONY:			pytestvirtual
pytestvirtual:
			make "PROJ_LOCAL_MODULES+=python-virtual" pytest

# package by creating the egg and wheel distribution binaries
.PHONY:			pypackage
pypackage:		$(MTARG_PYDIST_ATFC)
$(MTARG_PYDIST_ATFC):	$(MTARG_PYDIST_BDIR)
			@echo "egg no longer supported by PyPi--skipping"
			( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON_BIN) setup.py bdist_wheel )
			cp $(MTARG_PYDIST_ATFC)/* $(MTARG_PYDIST_DIR)
			@echo "create wheel in $(MTARG_PYDIST_DIR)"

# install the library locally
.PHONY:			pyinstall
pyinstall:		pytest pypackage
			$(PIP_BIN) install $(PIP_ARGS) $(MTARG_PYDIST_DIR)/*.whl

.PHONY:			pyinstallnotest
pyinstallnotest:
			make "PY_SRC_TEST=/dev/null" pyinstall

# create a pip distribution and upload it
.PHONY:			pydist
pydist:			$(MTARG_PYDIST_ATFC)
			@for url in $(PYPI_TEST_NAME) $(PYPI_NON_TEST_NAME) ; do \
			    $(PYTHON_BIN) -m twine upload --non-interactive \
				--sign-with $(PYPI_SIGN) --username $(PYPI_USER) \
				--repository $$url $(MTARG_PYDIST_ATFC)/* ; \
			done

# create wheel and its dependencies
.PHONY:			pywheel
pywheel:		$(MTARG_WHEEL_DIR)
$(MTARG_WHEEL_DIR):	$(MTARG_PYDIST_ATFC)
			mkdir -p $(MTARG_WHEEL_DIR)
			$(PIP_BIN) wheel --wheel-dir=$(MTARG_WHEEL_DIR) $(MTARG_PYDIST_ATFC)/*.whl

# uninstall locally
.PHONY:			pyuninstall
pyuninstall:		clean
			yes | $(PIP_BIN) uninstall `$(PYTHON_BIN) $(PY_SRC)/setup.py --name` || true

# clean up cached compiled source files
.PHONY:			pycleancache
pycleancache:
			find . -type d -name __pycache__ -prune -exec rm -r {} \;
