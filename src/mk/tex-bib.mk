BIBTEX=		BSTINPUTS=$(TIPATHSTR) bibtex
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(MTARG)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)

$(BBL_FILE):	$(BIB_FILE)
		cp $(BIB_FILE) $(MTARG)
		@echo "first latex rerun for bibtex..."
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
		@echo "running bibtex..."
		( cd $(MTARG) ; $(BIBTEX) $(TEX) $(QUIET) )
		@echo "second latex rerun for bibtex..."
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
