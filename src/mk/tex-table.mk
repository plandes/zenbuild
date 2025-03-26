# make module for creating latex tables from CSV files
#
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-table


## Module
#
# the script to generate the latex table
TEX_TAB_BIN ?=		datdesc
# directory to run the program assumes the parent Python path for imports
TEX_TAB_WD ?=		$(abspath ..)
# Python path include
TEX_PYTHON_SRC ?=	.
# where JSON table definitions live
TEX_TAB_DIR ?=		$(TEX_CONF_DIR)
# all table definitions
TEX_TAB_DEFS +=		$(wildcard $(TEX_TAB_DIR)/*-table.yml)
TEX_TAB_STYS =		$(addprefix $(TEX_LAT_PATH)/,$(notdir $(patsubst %.yml,%.sty,$(TEX_TAB_DEFS))))


## Build
#
INFO_TARGETS +=		textabinfo
TEX_PRE_COMP_DEPS +=	$(TEX_TAB_STYS)


## Targets
#
# build info
.PHONY:		textabinfo
textabinfo:
		@echo "tex-tab-defs: $(TEX_TAB_DEFS)"
		@echo "tex-tab-stys: $(TEX_TAB_STYS)"

# run the program to generate the tables
.PHONY:		textab
textab:
		@echo "creating $(TEX_TAB_STYS) in $(TEX_TAB_WD)"
		@( cd $(TEX_TAB_WD) ; \
		   PYTHONPATH=$(TEX_PYTHON_SRC) \
		   $(TEX_TAB_BIN) table $(TEX_TAB_DIR) $(TEX_LAT_PATH) )

# convenience: run the program, compile the PDF, then display it
.PHONY:		textabshow
textabshow:	textab show

# generate a new LaTeX .sty file for every *-table.yml found
%-table.sty:	$(TEX_TAB_DIR)/$(@F) $(TEX_MTARG_FILE)
		make textab
