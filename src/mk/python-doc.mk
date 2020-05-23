## make include file for creating Python documentation
## PL 5/21/2020

## includes
include $(BUILD_MK_DIR)/git-doc.mk

# sphinx binaries
PY_DOC_SPHINX_BIN ?=	sphinx-build
PY_DOC_SPHINX_APIDOC ?=	sphinx-apidoc

# build metadata
PY_DOC_META ?=		$(MTARG)/build.json

# doc paths
PY_DOC_DIR ?=		$(MTARG)/doc
PY_DOC_SETUP ?=		./src/doc
PY_DOC_SOURCE ?=	$(PY_DOC_DIR)/src
PY_DOC_BUILD ?=		$(GIT_DOC_SRC_DIR)

# build
INFO_TARGETS +=		pydocinfo


.PHONY:			pydocmeta
pydocmeta:		$(PY_DOC_META)

$(PY_DOC_META):
			mkdir -p $(MTARG)
			$(GTAGUTIL) write -f json > $(PY_DOC_META)

.PHONY:			pydocinfo
pydocinfo:
			@echo "py-sphinx-bin:  $(PY_DOC_SPHINX_BIN)"

.PHONY:			pydocclean
pydocclean:
			rm -f $(PY_COMPILED) || true

$(PY_DOC_SOURCE):	pydocclean
			mkdir -p $(PY_DOC_SOURCE)
			cp -r $(PY_DOC_SETUP)/* $(PY_DOC_SOURCE)
			cp README.md $(PY_DOC_SOURCE)/index.md
			[ -f CHANGELOG.md ] && cp CHANGELOG.md $(PY_DOC_SOURCE) || true
			[ -f LICENSE.md ] && cp LICENSE.md $(PY_DOC_SOURCE) || true
			cp -r doc $(PY_DOC_SOURCE)
			[ -d "test" ] && cp -r test $(PY_DOC_SOURCE)

.PHONY:			pydochtml
pydochtml:		$(PY_DOC_SOURCE) $(PY_DOC_META)
			PYTHONPATH=$(PY_SRC) $(PY_DOC_SPHINX_APIDOC) \
				-fT --implicit-namespaces \
				-o $(PY_DOC_SOURCE)/api $(PY_SRC)/zensols
			$(PY_DOC_SPHINX_BIN) -M html \
				"$(PY_DOC_SOURCE)" "$(PY_DOC_BUILD)"

.PHONY:			pydocshow
pydocshow:		pydochtml
			open $(PY_DOC_BUILD)/html/index.html
