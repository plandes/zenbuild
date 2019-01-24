# make module for creating bibtex (old) style bibliographies in latex

BIBTEX=		BSTINPUTS=$(TIPATHSTR) bibtex
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(LAT_COMP_PATH)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)
TEX_INIT_RUN = 	1


$(BBL_FILE):	$(BIB_FILE)
		cp $(BIB_FILE) $(LAT_COMP_PATH)
		@echo "running bibtex..."
		( cd $(LAT_COMP_PATH) ; $(BIBTEX) $(TEX) $(QUIET) )
