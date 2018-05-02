BIBTEX=		BSTINPUTS=$(TIPATHSTR) bibtex
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(MTARG)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)

$(BBL_FILE):	$(BIB_FILE)
		cp $(BIB_FILE) $(MTARG)
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
		( cd $(MTARG) ; $(BIBTEX) $(TEX) $(QUIET) )
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
