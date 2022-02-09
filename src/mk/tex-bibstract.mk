# make module for generating a .bib file from a master source .bib file

BIB_FILE ?=		$(TEX).bib
BIB_MASTER_FILE ?=
BIBSTRACT ?=		bibstract
ifdef BIBSTRACT_EXPORT_ALL
BIBSTRACT_SPACE :=	$(subst ,, )
# add entire tex path in colon syntax
BIBSTRACT_TEX_PATH ?=	$(subst $(BIBSTRACT_SPACE),:,$(TEX_PATH))
BIBSTRACT_ARGS ?=	exportall
else
BIBSTRACT_TEX_PATH ?=	..
BIBSTRACT_ARGS ?=	export
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
			$(BIBSTRACT) $(BIBSTRACT_ARGS) $(BIBSTRACT_TEX_PATH) > $(BIB_FILE)
