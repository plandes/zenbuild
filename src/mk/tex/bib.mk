# make module for creating bibtex (old) style bibliographies in latex
#
# to use, add the following to the make file:
# PROJ_MODULES= tex-bib


BIBTEX=		BSTINPUTS=$(TEX_PATHSTR) bibtex
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(TEX_LAT_PATH)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)
TEX_INIT_RUN = 	1


$(BBL_FILE):	$(BIB_FILE)
		@cp $(BIB_FILE) $(TEX_LAT_PATH)
		@echo "running bibtex on $(TEX_LAT_PATH)/$(TEX)..."
		@( cd $(TEX_LAT_PATH) ; $(BIBTEX) $(TEX) $(TEX_QUIET_REDIR) )
