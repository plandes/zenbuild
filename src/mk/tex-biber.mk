# make module for creating biber (new) style bibliographies in latex

BIBER ?=	BSTINPUTS=$(TIPATHSTR) biber
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(LAT_COMP_PATH)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)
TEX_INIT_RUN = 	1


$(BBL_FILE):	$(BIB_FILE)
		cp $(BIB_FILE) $(LAT_COMP_PATH)
		@echo "running biber..."
		( cd $(LAT_COMP_PATH) ; $(BIBER) $(TEX) $(QUIET) )

.PHONY:		cleanbib
cleanbib:
		sed -i '/^\s*urldate.*/d' $(BIB_FILE)
