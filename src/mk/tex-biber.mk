BIBER=		BSTINPUTS=$(TIPATHSTR) biber
BBL_FILE=	$(MTARG)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)

.PHONY:		biber
biber:		$(BBL_FILE)

$(BBL_FILE):	$(TEX).bib
		cp $(TEX).bib $(MTARG)
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
		( cd $(MTARG) ; $(BIBER) $(TEX) $(QUIET) )
