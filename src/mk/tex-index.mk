# make module for creating latex indexes
# don't forget to add \makeindex in the preamble

MAKEIDX_BIN ?=	makeindex
IDX_FILE ?=	$(TEX_LAT_PATH)/$(TEX).ilg
COMP_DEPS +=	$(IDX_FILE)
TEX_INIT_RUN = 	1

$(IDX_FILE):	$(TEX).tex
		@echo "running $(MAKEIDX_BIN)..."
		( cd $(TEX_LAT_PATH) ; $(MAKEIDX_BIN) $(TEX).idx $(TEX_QUIET_REDIR) )
