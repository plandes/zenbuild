#@meta {author: "Paul Landes"}
#@meta {desc: "creates a text version of the compiled pdf", date: "2025-09-05"}
#@meta {requires-command: "brew install poppler", order: "before"}
#@meta {install: "PROJ_LOCAL_MODULES += tex/text"}


## Module
#
# latex sources
TEX_TEXT_DEPS ?=	$(TEX_LAT_PATH)/$(TEX).tex
# derived text outputs
TEX_TEXT_FILES ?=	$(TEX_TEXT_DEPS:.tex=.txt)
# add to packaging used by `make install`
TEX_PKG_ADD +=		$(TEX_TEXT_FILES)


## Build
#
INFO_TARGETS +=		textextinfo


## Targets
#
# info
.PHONY:			textextinfo
textextinfo:
			@echo "tex-text-files: $(TEX_TEXT_FILES)"


# create a text version of the compiled pdf
%.txt:			%.pdf
			@echo "convert to text: $< -> $@"
			@pdftotext $< $@
.PHONY:			textext
textext:
			@$(MAKE) $(TEX_TEXT_FILES)
