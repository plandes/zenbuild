# python
PYTHON ?=	python
PY_SRC ?=	src/python
PY_SRC_TEST ?=	test/python
PY_COMPILED +=	$(shell find $(PY_SRC) -name \*.pyc -type f)
PY_CACHE +=	$(shell find $(PY_SRC) -type d -name __pycache__)
MTARG_PYDIST_DIR=	$(MTARG)/pydist
MTARG_PYDIST_BDIR=	$(MTARG_PYDIST_DIR)/build
MTARG_PYDIST_ATFC=	$(MTARG_PYDIST_BDIR)/dist

ADD_CLEAN +=	$(PY_COMPILED) $(PY_CACHE)

$(MTARG_PYDIST_BDIR):
	@echo "building egg in $(MTARG_PYDIST_BDIR)"
	mkdir -p $(MTARG_PYDIST_BDIR)
	cp -r $(PY_SRC)/* $(MTARG_PYDIST_BDIR)
	[ -f README.md ] && cp README.md $(MTARG_PYDIST_BDIR) || true
	[ -f LICENSE ] && cp LICENSE $(MTARG_PYDIST_BDIR)/LICENSE.txt || true

# run python tests
.PHONY:	pytest
pytest:
	@for i in $(PY_SRC_TEST)/* ; do \
		echo "testing $$i" ; \
		PYTHONPATH=$(PY_SRC) python $$i ; \
	done

# package by creating the egg and wheel distribution binaries
.PHONY:	pypackage
pypackage:	$(MTARG_PYDIST_ATFC)
$(MTARG_PYDIST_ATFC):	$(MTARG_PYDIST_BDIR)
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON) setup.py bdist_egg )
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON) setup.py bdist_wheel )
	cp $(MTARG_PYDIST_ATFC)/* $(MTARG_PYDIST_DIR)
	@echo "create egg in $(MTARG_PYDIST_DIR)"

# install the library locally
.PHONY:	pyinstall
pyinstall:	pypkg
#	pip install wheel
	pip install $(MTARG_PYDIST_DIR)/*.whl

# create a pip distribution and upload it
.PHONY:	pydist
pydist:	$(MTARG_PYDIST_BDIR)
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON) setup.py sdist upload -r pypitest )
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON) setup.py sdist upload -r pypi )
