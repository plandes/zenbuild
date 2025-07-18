# make module for creating biber (new) style bibliographies in latex
#
# to use, add the following to the make file:
# PROJ_MODULES= tex-biber


BIBER ?=	BSTINPUTS=$(TEX_PATHSTR) biber
BIB_FILE ?=	$(TEX).bib
BBL_FILE=	$(TEX_LAT_PATH)/$(TEX).bbl
COMP_DEPS +=	$(BBL_FILE)
TEX_INIT_RUN = 	1


$(BBL_FILE):	$(BIB_FILE)
		@cp $(BIB_FILE) $(TEX_LAT_PATH)
		@echo "running biber on $(TEX_LAT_PATH)/$(BIB_FILE)..."
		@if [ $(TEX_DEBUG) -eq 1 ] ; then \
			echo "( cd $(TEX_LAT_PATH) ; $(BIBER) $(TEX) $(TEX_QUIET_REDIR) )" ; \
		fi
		@( cd $(TEX_LAT_PATH) ; $(BIBER) $(TEX) $(TEX_QUIET_REDIR) )

.PHONY:		cleanbib
cleanbib:
		sed -i '/^\s*urldate.*/d' $(BIB_FILE)
