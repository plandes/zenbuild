## make include file for creating Python documentation
## PL 5/21/2020

# sphinx 
PY_DOC_SPHINX_BIN ?=	sphinx-build
PY_DOC_SPHINX_APIDOC ?=	sphinx-apidoc

PY_DOC_DIR ?=		$(MTARG)/doc
PY_DOC_SETUP ?=		./src/doc
PY_DOC_SOURCE ?=	$(PY_DOC_DIR)/src
PY_DOC_BUILD ?=		$(PY_DOC_DIR)/build

INFO_TARGETS +=		pydocinfo


.PHONY:			pydocinfo
pydocinfo:
			@echo "py-sphinx-bin:  $(PY_DOC_SPHINX_BIN)"

.PHONY:			pydocclean
pydocclean:
			rm -f $(PY_COMPILED) || true

.PHONY:			pydoccp
pydoccp:		pydocclean $(PY_DOC_SOURCE)

$(PY_DOC_SOURCE):
			mkdir -p $(PY_DOC_SOURCE)
			cp -r $(PY_DOC_SETUP)/* $(PY_DOC_SOURCE)

.PHONY:			pydochtml
pydochtml:		$(PY_DOC_SOURCE)
			PYTHONPATH=$(PY_SRC) $(PY_DOC_SPHINX_APIDOC) \
				-fT --implicit-namespaces \
				-o $(PY_DOC_SOURCE)/api $(PY_SRC)/zensols
			$(PY_DOC_SPHINX_BIN) -M html \
				"$(PY_DOC_SOURCE)" "$(PY_DOC_BUILD)"

.PHONY:			pydocshow
pydocshow:		pydochtml
			open $(PY_DOC_BUILD)/html/index.html
