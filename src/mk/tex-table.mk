# make module for creating latex tables from CSV files
#
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-table


# the script to generate the latex table
TEX_TAB_BIN ?=		datdesc
# where JSON table definitions live
TEX_TAB_DIR ?=		$(TEX_CONF_DIR)
# all table definitions
TEX_TAB_DEFS +=		$(wildcard $(TEX_TAB_DIR)/*-table.yml)
TEX_TAB_STYS =		$(addprefix $(TEX_LAT_PATH)/,$(notdir $(patsubst %.yml,%.sty,$(TEX_TAB_DEFS))))

# build
INFO_TARGETS +=		textabinfo
TEX_PRE_COMP_DEPS +=	$(TEX_TAB_STYS)


.PHONY:		textabinfo
textabinfo:
		@echo "tex-tab-defs: $(TEX_TAB_DEFS)"
		@echo "tex-tab-stys: $(TEX_TAB_STYS)"

.PHONY:		textab
textab:
		@echo "creating $(TEX_TAB_STYS)"
		$(TEX_TAB_BIN) table $(TEX_TAB_DIR) $(TEX_LAT_PATH)

.PHONY:		textabshow
textabshow:
		@echo "creating $(TEX_TAB_STYS)"
		$(TEX_TAB_BIN) table $(TEX_TAB_DIR) $(TEX_LAT_PATH)
		make show

%-table.sty:	$(TEX_TAB_DIR)/$(@F) $(TEX_MTARG_FILE)
		make textab
