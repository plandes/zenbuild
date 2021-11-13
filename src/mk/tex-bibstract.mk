# make module for generating a .bib file from a master source .bib file

BIB_FILE ?=		$(TEX).bib
BIB_MASTER_FILE ?=
BIBSTRACT_TEX_PATH ?=	..
BIBSTRACT ?=		bibstract
COMP_DEPS +=		$(BIB_FILE)
ADD_CLEAN_ALL +=	$(BIB_FILE)

.PHONY:			texbibstract
texbibstract:		$(BIB_FILE)

.PHONY:			texcleanbibstract
texcleanbibstract:
			rm -rf $(BIB_FILE)

$(BIB_FILE):		$(BIB_MASTER_FILE)
			@echo "running bibstract on $(BIB_FILE)..."
			$(BIBSTRACT) export $(BIBSTRACT_TEX_PATH) > $(BIB_FILE)
