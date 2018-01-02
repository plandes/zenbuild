# python
PYTHON_BIN ?=		python
PIP_BIN ?=		pip
PY_SRC ?=		src/python
PY_SRC_CLI ?=		src/bin
PY_SRC_TEST ?=		test/python
PY_SRC_TEST_PKGS ?=	$(basename $(notdir $(wildcard $(PY_SRC_TEST)/*.py)))
PY_COMPILED +=		$(shell find $(PY_SRC) -name \*.pyc -type f)
PY_CACHE +=		$(shell find $(PY_SRC) -type d -name __pycache__)
MTARG_PYDIST_DIR=	$(MTARG)/pydist
MTARG_PYDIST_BDIR=	$(MTARG_PYDIST_DIR)/build
MTARG_PYDIST_ATFC=	$(MTARG_PYDIST_BDIR)/dist
ADD_CLEAN +=		$(PY_COMPILED) $(PY_CACHE)
INFO_TARGETS +=		pythoninfo

.PHONY: pythoninfo
pythoninfo:
	@echo "interpreter: $(PYTHON_BIN)"
	@echo "py-src: $(PY_SRC)"
	@echo "py-test: $(PY_SRC_TEST)"
	@echo "py-test-pkgs: $(PY_SRC_TEST_PKGS)"
	@echo "clean: $(ADD_CLEAN)"

$(MTARG_PYDIST_BDIR):
	@echo "building egg in $(MTARG_PYDIST_BDIR)"
	mkdir -p $(MTARG_PYDIST_BDIR)
	cp -r $(PY_SRC)/* $(MTARG_PYDIST_BDIR)
	[ -f README.md ] && cp README.md $(MTARG_PYDIST_BDIR) || true
	[ -f LICENSE ] && cp LICENSE $(MTARG_PYDIST_BDIR)/LICENSE.txt || true

# install deps
.PHONY:	pydeps
pydeps:
	$(PIP_BIN) install -r $(PY_SRC)/requirements.txt

# run python tests
.PHONY:	pytest
pytest:
	@for i in $(PY_SRC_TEST_PKGS) ; do \
		echo "testing $$i" ; \
		PYTHONPATH=$(PY_SRC):$(PY_SRC_TEST) $(PYTHON_BIN) -m unittest $$i ; \
	done

# run python clis
.PHONY:	pyrun
pyrun:
	@for i in $(PY_SRC_CLI)/* ; do \
		echo "running $$i" ; \
		PYTHONPATH=$(PYTHONPATH):$(PY_SRC) $(PYTHON_BIN) $$i ; \
	done

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
pyinstall:	pypackage
	$(PIP_BIN) install $(MTARG_PYDIST_DIR)/*.whl

# create a pip distribution and upload it
.PHONY:	pydist
pydist:	$(MTARG_PYDIST_BDIR)
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON_BIN) setup.py sdist upload -r pypitest )
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON_BIN) setup.py sdist upload -r pypi )

.PHONY:	pyuninstall
pyuninstall:
	yes | $(PIP_BIN) uninstall `$(PYTHON_BIN) $(PY_SRC)/setup.py --name` || true
