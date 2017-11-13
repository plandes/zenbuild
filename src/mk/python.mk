# python
PYTHON ?=	python
PY_SRC ?=	src/python
PY_SRC_TEST ?=	test/python
PY_COMPILED +=	$(shell find $(PY_SRC) -name \*.pyc -type f)
MTARG_PYDIST_DIR=	$(MTARG)/pydist
MTARG_PYDIST_BDIR=	$(MTARG_PYDIST_DIR)/build
MTARG_PYDIST_ATFC=	$(MTARG_PYDIST_BDIR)/dist

ADD_CLEAN +=	$(PY_COMPILED)

$(MTARG_PYDIST_BDIR):
	@echo "building egg in $(MTARG_PYDIST_BDIR)"
	mkdir -p $(MTARG_PYDIST_BDIR)
	cp -r $(PY_SRC)/* $(MTARG_PYDIST_BDIR)

.PHONY:	pydist
pydist:	$(MTARG_PYDIST_DIR)
$(MTARG_PYDIST_DIR):	$(MTARG_PYDIST_BDIR)
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON) setup.py bdist_egg )
	( cd $(MTARG_PYDIST_BDIR) ; $(PYTHON) setup.py bdist_wheel )
	cp $(MTARG_PYDIST_ATFC)/* $(MTARG_PYDIST_DIR)
	@echo "create egg in $(MTARG_PYDIST_DIR)"

.PHONY:	pyinstall
pyinstall:	pydist
#	pip install wheel
	pip install $(MTARG_PYDIST_DIR)/*.whl

.PHONY:	pytest
pytest:
	@for i in $(PY_SRC_TEST)/* ; do \
		echo "testing $$i" ; \
		PYTHONPATH=$(PY_SRC) python $$i ; \
	done
