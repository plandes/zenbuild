BIBER=		BSTINPUTS=$(TIPATHSTR) biber
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(MTARG)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)

$(BBL_FILE):	$(BIB_FILE)
		cp $(BIB_FILE) $(MTARG)
		@echo "first latex rerun for labibtex..."
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
		@echo "running labibtex..."
		( cd $(MTARG) ; $(BIBER) $(TEX) $(QUIET) )
