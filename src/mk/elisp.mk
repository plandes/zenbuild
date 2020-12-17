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

# package-lint
# A space-separated list of required package names
EL_NEEDED_PACKAGES ?=	package-lint

# code to evaluate to download and install package-lint for target ellint
EL_INIT_INSTALL = "(progn \
   (require 'package) \
   (push '(\"melpa\" . \"https://melpa.org/packages/\") package-archives) \
   (package-initialize) \
   (dolist (pkg '(${EL_NEEDED_PACKAGES})) \
     (unless (package-installed-p pkg) \
       (unless (assoc pkg package-archive-contents) \
         (package-refresh-contents)) \
       (package-install pkg) \
       (require pkg))))"

# instead of installing, assume Cask has installed package dependencies
# the second path element is the Emacs version dependency in the package file
EL_INIT_CASK = "(progn \
    (setq package-user-dir (car (file-expand-wildcards \".cask/*/elpa\"))) \
    (require 'package-lint))"

EL_INIT ?= $(EL_INIT_CASK)

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

# clean compiled Emacs Lisp files, which is useful for forcing recompilation to
# get byte compiled warnings/errors
.PHONY:			elcleancompiled
elcleancompiled:
			rm -f $(EL_OBJECTS)


# build/compile
.PHONY:			elbuild
elbuild:		$(EL_ELPA_FILE) $(EL_OBJECTS)

# run unit tests
.PHONY:			eltest
eltest:			elcleancompiled elbuild ellint
			@if [ -d test ] ; then \
				$(EL_CASK_BIN) exec ert-runner -L $(EL_LISP_DIR) ; \
			fi

# lint
.PHONY:			ellint
ellint:			eldeps
			@echo "running package lint"
	        	@$(EL_CASK_BIN) emacs $$i $(EL_EMACS_SWITCHES) --batch \
				-eval $(EL_INIT) \
				-f package-lint-batch-and-exit $(EL_FILES)
			@echo "package lint successful"

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
