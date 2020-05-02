## make include file for Python projects
## PL 7/20/2018

## config

# python
PYTHON_BIN ?=		python
PYTHON_BIN_ARGS ?=	
PYTHON_TEST_ARGS ?=	
PIP_BIN ?=		$(PYTHON_BIN) -m pip

# python path
PY_SRC ?=		src/python
PY_SRC_CLI ?=		src/bin
PY_SRC_TEST ?=		test/python
PY_SRC_TEST_PAT ?=	'test_*.py'
PY_TEST_DEPS +=
PY_RUN_DEPS +=
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
PYPI_TEST_URL ?=	https://test.pypi.org/legacy/
PYPI_NON_TEST_URL ?=	https://upload.pypi.org/legacy/
PYPI_USER ?=		pypiuser
PYPI_SIGN ?=		pypiuser@example.com

# build
ADD_CLEAN +=		$(PY_COMPILED) $(PY_CACHE)
ADD_CLEAN_ALL +=	$(PY_FLYMAKE)
INFO_TARGETS +=		pyinfo


# targets
.PHONY: pyinfo
pyinfo:
	@echo "interpreter: $(PYTHON_BIN)"
	@echo "py-src: $(PY_SRC)"
	@echo "py-test: $(PY_SRC_TEST)"
	@echo "py-test-test-pat: $(PY_SRC_TEST_PAT)"
	@echo "py-dist-atfc: $(MTARG_PYDIST_ATFC)"
	@echo "py-dist-res: $(MTARG_PYDIST_RES)"

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

# install deps
.PHONY:	pydeps
pydeps:
	$(PIP_BIN) install -r $(PY_SRC)/requirements.txt

# run python tests
.PHONY:	pytest
pytest:	$(PY_TEST_DEPS)
	@PYTHONPATH=$(PY_SRC):$(PY_SRC_TEST) $(PYTHON_BIN) \
		$(PYTHON_TEST_ARGS) -m unittest discover \
		-s $(PY_SRC_TEST) -p $(PY_SRC_TEST_PAT) -v

# run tests in a virtual environment
.PHONY:	pytestvirtual
pytestvirtual:
	make "PROJ_LOCAL_MODULES+=python-virtual" pytest

# run python clis
.PHONY:	pyrun
pyrun:	$(PY_RUN_DEPS)
	@for i in $(PY_SRC_CLI)/* ; do \
		echo "running $$i" ; \
		PYTHONPATH=$(PYTHONPATH):$(PY_SRC) $(PYTHON_BIN) \
			$$i $(PYTHON_BIN_ARGS) ; \
	done

# display the command line help usage
.PHONY:	pyhelp
pyhelp:
	make PYTHON_BIN_ARGS='--help' pyrun

# package by creating the egg and wheel distribution binaries
.PHONY:	pypackage
pypackage:	$(MTARG_PYDIST_ATFC)
$(MTARG_PYDIST_ATFC):	$(MTARG_PYDIST_BDIR)
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON_BIN) setup.py bdist_egg )
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON_BIN) setup.py bdist_wheel )
	cp $(MTARG_PYDIST_ATFC)/* $(MTARG_PYDIST_DIR)
	@echo "create egg in $(MTARG_PYDIST_DIR)"

# install the library locally
.PHONY:	pyinstall
pyinstall:	pytest pypackage
	$(PIP_BIN) install $(MTARG_PYDIST_DIR)/*.whl

.PHONY:	pyinstallnotest
pyinstallnotest:
	make "PY_SRC_TEST_PAT=NONE" "PY_TEST_DEPS=" pyinstall

# create a pip distribution and upload it
.PHONY:	pydist
pydist:	$(MTARG_PYDIST_ATFC)
	@for url in $(PYPI_TEST_URL) $(PYPI_NON_TEST_URL) ; do \
		$(PYTHON_BIN) -m twine upload \
			--sign-with $(PYPI_SIGN) --username $(PYPI_USER) \
			--repository-url $$url $(MTARG_PYDIST_ATFC)/* ; \
	done

# create wheel and its dependencies
.PHONY:	pywheel
pywheel:$(MTARG_WHEEL_DIR)
$(MTARG_WHEEL_DIR):	$(MTARG_PYDIST_ATFC)
	mkdir -p $(MTARG_WHEEL_DIR)
	$(PIP_BIN) wheel --wheel-dir=$(MTARG_WHEEL_DIR) $(MTARG_PYDIST_ATFC)/*.whl

# uninstall locally
.PHONY:	pyuninstall
pyuninstall:	clean
	yes | $(PIP_BIN) uninstall `$(PYTHON_BIN) $(PY_SRC)/setup.py --name` || true
