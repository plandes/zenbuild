# make module for creating bibtex (old) style bibliographies in latex

BIBTEX=		BSTINPUTS=$(TIPATHSTR) bibtex
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(MTARG)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)
TEX_INIT_RUN = 	1

$(BBL_FILE):	$(BIB_FILE)
		cp $(BIB_FILE) $(MTARG)
		@echo "running bibtex..."
		( cd $(MTARG) ; $(BIBTEX) $(TEX) $(QUIET) )
