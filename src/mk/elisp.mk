## make include file for Emacs Lisp projects
## PL 7/07/2019

## includes
include $(BUILD_MK_DIR)/emacs.mk

## config
# emacs lisp
EL_APP_NAME ?=		$(shell grep package-file Cask | sed 's/.*\"\(.*\)\.el.*/\1/')
EL_CASK_BIN ?=		EMACS=$(EMACS_BIN) cask
EL_LISP_DIR ?=		.
EL_DOC_DIR ?=		doc
EL_ELPA_FILE ?=		elpa
EL_FILES +=		$(wildcard $(EL_LISP_DIR)/*.el)
EL_OBJECTS +=		$(EL_FILES:.el=.elc)
EL_DIST_DIR ?=		dist
EL_EMACS_SWITCHES +=	-q

# build environment
ADD_CLEAN +=		$(EL_OBJECTS) $(EL_ELPA_FILE) $(EL_DOC_DIR) $(EL_DIST_DIR)
ADD_CLEAN_ALL +=	.cask
INFO_TARGETS +=		elinfo


## targets
.PHONY: 		elinfo
elinfo:
			@echo "el-app-name: $(EL_APP_NAME)"
			@echo "el-files: $(EL_FILES)"
			@echo "el-objects: $(EL_OBJECTS)"

# list package files
.PHONY:			eldistfiles
eldistfiles:
			$(EL_CASK_BIN) files

# patterns
%.elc:			%.el
			$(EL_CASK_BIN) build
			@echo "cask build complete"

# lifecycle
$(EL_ELPA_FILE):
			$(EL_CASK_BIN) install || true
			$(EL_CASK_BIN) update
			touch $@

# cask downloads and installs dependencies found in the `Cask` file
.PHONY:			eldeps
eldeps:			$(EL_ELPA_FILE)

# build/compile
.PHONY:			elbuild
elbuild:		$(EL_ELPA_FILE) $(EL_OBJECTS)

# run unit tests
.PHONY:			eltest
eltest:			elbuild ellint
			@if [ -d test ] ; then \
				$(EL_CASK_BIN) exec ert-runner -L $(EL_LISP_DIR) ; \
			fi

# lint
.PHONY:			ellint
ellint:			eldeps
			@echo "running package lint"
	        	@$(EL_CASK_BIN) emacs $$i $(EL_EMACS_SWITCHES) --batch \
				-eval "(require 'package-lint)"\
				-f package-lint-batch-and-exit $(EL_FILES) \
				|| true

# docs
$(EL_DOC_DIR):
			mkdir -p $(EL_DOC_DIR)
			@if [ -f README.md ] ; then \
				pandoc README.md -s -o $(EL_DOC_DIR)/$(EL_APP_NAME).texi ; \
			fi

.PHONY:			eldoc
eldoc:			$(EL_DOC_DIR)

# package
.PHONY:			elpackage
elpackage:		eltest eldoc ellint
			$(EL_CASK_BIN) package
			@echo "created distribution in $(EL_DIST_DIR) and docs in $(EL_DOC_DIR)"

# deploy: assume melpa, which collects from github
.PHONY:			eldeploy
eldeploy:		gitgithubpush
