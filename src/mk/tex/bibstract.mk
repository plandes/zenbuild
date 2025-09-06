#@meta {author: "Paul Landes"}
#@meta {desc: "generate .bib from a master source .bib file", date: "2025-09-05"}
#@meta {install: "PROJ_LOCAL_MODULES += tex/bibstract"}


## Environment
#
BIB_FILE ?=		$(TEX).bib
BIB_MASTER_FILE ?=
BIBSTRACT ?=		bibstract
BIBSTRACT_ARGS ?=	export
ifdef BIBSTRACT_EXPORT_ALL
# add entire tex path in colon syntax
BIBSTRACT_TEX_PATH ?=	$(TEX_PATHSEP)
else
BIBSTRACT_TEX_PATH ?=	..
endif
COMP_DEPS +=		$(BIB_FILE)
ADD_CLEAN_ALL +=	$(BIB_FILE)


## Targets
#
# create the .bib file
.PHONY:			texbibstract
texbibstract:		$(BIB_FILE)

# the .bib file target
$(BIB_FILE):		$(BIB_MASTER_FILE)
			@echo "running bibstract on $(BIB_FILE)..."
			@$(BIBSTRACT) $(BIBSTRACT_ARGS) $(BIBSTRACT_TEX_PATH) \
				--output $(BIB_FILE)

# remove the .bib file, which forces its recreation on the next compile
.PHONY:			texcleanbibstract
texcleanbibstract:
			rm -rf $(BIB_FILE)

# force recreate the .bib file
.PHONY:			texrebibstract
texrebibstract:		texcleanbibstract texbibstract
