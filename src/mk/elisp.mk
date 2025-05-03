#@meta {author: "Paul Landes"}
#@meta {desc: "include for Emacs Lisp projects", date: "2019-07-07"}


## Includes
#
include $(BUILD_MK_DIR)/emacs.mk

## Config
#
# emacs lisp
EL_APP_NAME ?=		$(shell grep package-file Cask | sed 's/.*\"\(.*\)\.el.*/\1/')
EL_CASK_BIN ?=		EMACS=$(EMACS_BIN) cask
EL_LISP_DIR ?=		.
EL_DOC_DIR ?=		doc
EL_ELPA_FILE ?=		elpa
EL_DEPS +=		$(EL_ELPA_FILE)
EL_FILES +=		$(wildcard $(EL_LISP_DIR)/*.el)
EL_OBJECTS +=		$(EL_FILES:.el=.elc)
EL_DIST_DIR ?=		$(MTARG)/dist
EL_EMACS_SWITCHES +=	-q
# set to skip package lint
EL_SKIP_LINT ?=


## Build environment
#
ADD_CLEAN +=		$(EL_OBJECTS) $(EL_ELPA_FILE) $(EL_DOC_DIR)
ADD_CLEAN_ALL +=	.cask
INFO_TARGETS +=		elinfo

## Package-lint
#
# A space-separated list of required package names
EL_NEEDED_PACKAGES ?=	package-lint

# evaluate to download and install package-lint
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

# evaluate on target 'ellint'
EL_INIT ?= 		$(EL_INIT_INSTALL)


## Targets
#
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
eldeps:			$(EL_DEPS)

# clean compiled Emacs Lisp files, which is useful for forcing recompilation to
# get byte compiled warnings/errors
.PHONY:			elcleancompiled
elcleancompiled:
			rm -f $(EL_OBJECTS)


# build/compile
.PHONY:			elbuild
elbuild:		$(EL_BUILD_DEPS) $(EL_ELPA_FILE) $(EL_OBJECTS)

# run unit tests
.PHONY:			eltest
eltest:			elcleancompiled elbuild ellint
			@if [ -d test ] ; then \
				$(EL_CASK_BIN) exec ert-runner -L $(EL_LISP_DIR) ; \
			fi

# lint
.PHONY:			ellint
ellint:			eldeps
			@if [ -z "$(EL_SKIP_LINT)" ] ; then \
				echo "running package lint" ; \
		        	$(EL_CASK_BIN) emacs $$i $(EL_EMACS_SWITCHES) --batch \
					-eval $(EL_INIT) \
					-f package-lint-batch-and-exit $(EL_FILES) ; \
				echo "package lint successful" ; \
			else \
				echo "skipping package lint" ; \
			fi

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
			mkdir -p $(MTARG)
			$(EL_CASK_BIN) package $(EL_DIST_DIR)
			@echo "created distribution in $(EL_DIST_DIR) and docs in $(EL_DOC_DIR)"

# deploy: assume melpa, which collects from github
.PHONY:			eldeploy
eldeploy:		gitgithubpush
