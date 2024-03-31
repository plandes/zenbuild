# make module for generating a .bib file from a master source .bib file
#
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-bibstract


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

.PHONY:			texbibstract
texbibstract:		$(BIB_FILE)

.PHONY:			texcleanbibstract
texcleanbibstract:
			rm -rf $(BIB_FILE)

$(BIB_FILE):		$(BIB_MASTER_FILE)
			@echo "running bibstract on $(BIB_FILE)..."
			$(BIBSTRACT) $(BIBSTRACT_ARGS) $(BIBSTRACT_TEX_PATH) --output $(BIB_FILE)
