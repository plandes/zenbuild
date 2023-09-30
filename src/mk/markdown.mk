## make include file for markdown -> html using pandac
## PL 6/19/2023

## Build configuration
#
# executables
MD_PANDOC_BIN ?=	pandoc
MD_SHOWPREV_BIN ?=	rend

# metadata
MD_SRC_NAME ?=		README
MD_SRC_FILE =		$(MD_SRC_NAME).md
MD_TITLE ?=		$(shell head -1 $(MD_SRC_FILE) | sed 's/^#\s*\(.*\)/\1/')

# paths
MD_GITHUB_CSS ?=	$(BUILD_SRC_DIR)/template/markdown/github.css
# install/distribution
MD_INSTALL_DIR ?=	$(HOME)/Desktop
MD_INSTALL_FILE ?=	$(MD_INSTALL_DIR)/$(MD_SRC_NAME).zip

# dependencies
MD_HTML_FILE ?=		$(addprefix $(MTARG)/$(MD_SRC_NAME),.html)
MD_PDF_FILE ?=		$(addprefix $(MTARG)/$(MD_SRC_NAME),.pdf)
MD_DERIVE_FILES =	$(MD_HTML_FILE) $(MD_PDF_FILE)
MD_MTARG_DEPS +=
MD_DEPS +=		$(MTARG) $(MD_DERIVE_FILES)

# build system
INFO_TARGETS +=		markdowninfo


## Targets
#
.PHONY:			markdowninfo
markdowninfo:
			@echo "md-src-file: $(MD_SRC_FILE)"

# create the `target` directory for derived objects
$(MTARG):		$(MD_MTARG_DEPS)
			mkdir -p $(MTARG)

# convert the markdown file to html and pdf files
.PHONY:			markdown-package
markdown-package:	$(MD_DEPS)

# create and show the html document
.PHONY:			markdown-show-html
markdown-show-html:	$(MTARG) $(MD_HTML_FILE)
			$(MD_SHOWPREV_BIN) show $(MTARG)/$(MD_SRC_NAME).html

# create and show the pdf document
.PHONY:			markdown-show-pdf
markdown-show-pdf:	$(MTARG) $(MD_PDF_FILE)
			$(MD_SHOWPREV_BIN) show $(MTARG)/$(MD_SRC_NAME).pdf

# force a recompile for all files
.PHONY:			markdown-force-compile
markdown-force-compile:
			touch $(MD_SRC_FILE)
			make package

# create a zip file on the desktop with the pandoc compiled files
.PHONY:			markdown-install
markdown-install:	$(MD_INSTALL_FILE)
			@echo "installed to $(MD_INSTALL_FILE)"

$(MD_INSTALL_FILE):	markdown-package
			mkdir -p $(MTARG)/$(MD_SRC_NAME)
			cp $(MD_DERIVE_FILES) $(MTARG)/$(MD_SRC_NAME)
			cp $(MD_SRC_FILE) $(MTARG)/$(MD_SRC_NAME)
			( cd $(MTARG) ; zip -r $(MD_SRC_NAME).zip $(MD_SRC_NAME) )
			cp $(MTARG)/$(MD_SRC_NAME).zip $(MD_INSTALL_FILE)

# pandoc compile an html file
%.html:			$(MD_SRC_FILE)
			@echo "compiling HTML"
			$(MD_PANDOC_BIN) --from=gfm --to=html \
				--metadata title="" \
				--metadata pagetitle="$(MD_TITLE)" \
				--css="$(MD_GITHUB_CSS)" \
				--self-contained \
				$(MD_SRC_FILE) --output $@

# pandoc compile a pdf file
%.pdf:			$(MD_SRC_FILE)
			@echo "compiling PDF $*.md -> $@"
			$(MD_PANDOC_BIN) --from=gfm --to=pdf \
				$(MD_SRC_FILE) --output $@
