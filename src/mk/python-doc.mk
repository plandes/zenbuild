## make include file for creating Python documentation
## PL 5/21/2020


## python doc

# sphinx
PY_DOC_SPHINX_BIN ?=	sphinx-build
PY_DOC_SPHINX_APIDOC ?=	sphinx-apidoc

# doc paths
PY_DOC_DIR ?=		$(MTARG)/doc
PY_DOC_MD_SRC ?=	./doc
PY_DOC_CONF_SRC ?=	./src/doc
PY_DOC_SOURCE_DEPS +=	
PY_DOC_SOURCE ?=	$(PY_DOC_DIR)/src
PY_DOC_BUILD ?=		$(PY_DOC_DIR)/build
PY_DOC_BUILD_API ?=	$(PY_DOC_SOURCE)/api
PY_DOC_BUILD_HTML ?=	$(PY_DOC_BUILD)/html
PY_DOC_BUILD_PDF ?=	$(PY_DOC_BUILD)/pdf
# HTML deps; add targets to copy static content that ends up on github.io
PY_DOC_BUILD_HTML_DEPS += $(PY_DOC_BUILD_API)

# doc configuration
PY_DOC_CONF_BIN ?=	$(BUILD_BIN_DIR)/pyconfdoc.py
PY_DOC_CONF_TMPLT ?=	$(BUILD_SRC_DIR)/template/python-doc
PY_DOC_CONF_TMPLT_A ?=	$(BUILD_SRC_DIR)/template/sphinx-apidoc
PY_DOC_CONF_ARGS_SUP ?=
PY_DOC_CONF_ARGS +=	$(GIT_BUILD_INFO) $(PY_DOC_CONF_SRC) $(PY_DOC_CONF_TMPLT) \
			$(PY_DOC_SOURCE) $(PY_DOC_CONF_ARGS_SUP)

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

.PHONY:			pydocsrc
pydocsrc:		$(PY_DOC_SOURCE)

$(PY_DOC_SOURCE):	$(PY_DOC_SOURCE_DEPS)
			mkdir -p $(PY_DOC_SOURCE)
			cp README.md $(PY_DOC_SOURCE)/index.md
			[ -f CHANGELOG.md ] && cp CHANGELOG.md $(PY_DOC_SOURCE) || true
			[ -f LICENSE.md ] && cp LICENSE.md $(PY_DOC_SOURCE) || true
			[ -f CONTRIBUTING.md ] && cp CONTRIBUTING.md $(PY_DOC_SOURCE) || true
			[ -d $(PY_DOC_MD_SRC) ] && cp -r $(PY_DOC_MD_SRC) $(PY_DOC_SOURCE)/doc || true
			[ -d "test" ] && cp -r test $(PY_DOC_SOURCE) || true
			$(PY_DOC_CONF_BIN) $(PY_DOC_CONF_ARGS)

.PHONY:			pydochtml
pydochtml:		$(PY_DOC_BUILD_HTML)

.PHONY:			pydocpdf
pydocpdf:		$(PY_DOC_BUILD_PDF)

$(PY_DOC_BUILD_API):	$(PY_DOC_SOURCE)
			$(eval SDIR=$(shell find $(PY_SRC) -maxdepth 1 -mindepth 1 -type d))
			@echo "using source directory $(CODE_DIR)"
			PYTHONPATH=$(PY_SRC) $(PY_DOC_SPHINX_APIDOC) \
				-fT --implicit-namespaces \
				--templatedir $(PY_DOC_CONF_TMPLT_A) \
				-o $(PY_DOC_BUILD_API) $(SDIR)

$(PY_DOC_BUILD_HTML):	$(PY_DOC_BUILD_HTML_DEPS)
			$(PY_DOC_SPHINX_BIN) -M html \
				"$(PY_DOC_SOURCE)" "$(PY_DOC_BUILD)"
			touch $(PY_DOC_BUILD_HTML)/.nojekyll

$(PY_DOC_BUILD_PDF):	$(PY_DOC_BUILD_API)
			$(PY_DOC_SPHINX_BIN) -M pdf \
				"$(PY_DOC_SOURCE)" "$(PY_DOC_BUILD)"

.PHONY:			pydocshow
pydocshow:		pydochtml
			open $(PY_DOC_BUILD_HTML)/index.html
