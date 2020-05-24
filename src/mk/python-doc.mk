## make include file for creating Python documentation
## PL 5/21/2020


## python doc

# executables
PY_DOC_SPHINX_BIN ?=	sphinx-build
PY_DOC_SPHINX_APIDOC ?=	sphinx-apidoc
PY_DOC_TOPDOC_BIN ?=	$(BUILD_BIN_DIR)/pytopdoc.py

# doc paths
PY_DOC_DIR ?=		$(MTARG)/doc
PY_DOC_SETUP ?=		./src/doc
PY_DOC_SOURCE ?=	$(PY_DOC_DIR)/src
PY_DOC_BUILD ?=		$(PY_DOC_DIR)/build
PY_DOC_BUILD_API ?=	$(PY_DOC_SOURCE)/api
PY_DOC_BUILD_HTML ?=	$(PY_DOC_BUILD)/html
PY_DOC_BUILD_PDF ?=	$(PY_DOC_BUILD)/pdf

# git-doc config
GIT_DOC_SRC_DIR =	$(PY_DOC_BUILD_HTML)


## build
INFO_TARGETS +=		pydocinfo


## includes
# this requires PROJ_MODULES=git
include $(BUILD_MK_DIR)/git-doc.mk


## targets

.PHONY:			pydocinfo
pydocinfo:
			@echo "py-sphinx-bin: $(PY_DOC_SPHINX_BIN)"

tmp:			$(PY_DOC_SOURCE)

$(PY_DOC_SOURCE):
			mkdir -p $(PY_DOC_SOURCE)
			cp -r $(PY_DOC_SETUP)/* $(PY_DOC_SOURCE)
			cp README.md $(PY_DOC_SOURCE)/index.md
			[ -f CHANGELOG.md ] && cp CHANGELOG.md $(PY_DOC_SOURCE) || true
			[ -f LICENSE.md ] && cp LICENSE.md $(PY_DOC_SOURCE) || true
			cp -r doc $(PY_DOC_SOURCE)
			[ -d "test" ] && cp -r test $(PY_DOC_SOURCE)
			$(PY_DOC_TOPDOC_BIN) . src/doc/top.rst \
				$(PY_DOC_SOURCE)/top.rst

.PHONY:			pydochtml
pydochtml:		$(PY_DOC_BUILD_HTML)

.PHONY:			pydocpdf
pydocpdf:		$(PY_DOC_BUILD_PDF)

$(PY_DOC_BUILD_API):	$(PY_DOC_SOURCE)
			PYTHONPATH=$(PY_SRC) $(PY_DOC_SPHINX_APIDOC) \
				-fT --implicit-namespaces \
				-o $(PY_DOC_BUILD_API) $(PY_SRC)/zensols

$(PY_DOC_BUILD_HTML):	$(PY_DOC_BUILD_API)
			$(PY_DOC_SPHINX_BIN) -M html \
				"$(PY_DOC_SOURCE)" "$(PY_DOC_BUILD)"
			touch $(PY_DOC_BUILD_HTML)/.nojekyll

$(PY_DOC_BUILD_PDF):	$(PY_DOC_BUILD_API)
			$(PY_DOC_SPHINX_BIN) -M pdf \
				"$(PY_DOC_SOURCE)" "$(PY_DOC_BUILD)"

.PHONY:			pydocshow
pydocshow:		pydochtml
			open $(PY_DOC_BUILD_HTML)/index.html
