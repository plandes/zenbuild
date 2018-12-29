# make module for creating latex indexes
# don't forget to add \makeindex in the preamble

MAKEIDX_BIN ?=	makeindex
IDX_FILE ?=	$(MTARG)/$(TEX).ilg
COMP_DEPS +=	$(IDX_FILE)
TEX_INIT_RUN = 	1

$(IDX_FILE):	$(TEX).tex
		@echo "running $(MAKEIDX_BIN)..."
		( cd $(MTARG) ; $(MAKEIDX_BIN) $(TEX).idx $(QUIET) )
