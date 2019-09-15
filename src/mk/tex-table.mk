# make module for creating latex tables from CSV files
# 9/15/2019

# the script to generate the latex table
TEX_TAB_BIN ?=	$(BUILD_BIN_DIR)/mklatextbl.py
# where JSON table definitions live
TEX_TAB_DIR ?=	$(abspath ../table)
# all table definitions
TEX_TAB_DEFS +=	$(wildcard $(TEX_TAB_DIR)/*.json)
TEX_TAB_STYS =	$(addprefix $(LAT_COMP_PATH)/,$(notdir $(patsubst %.json,%-tab.sty,$(TEX_TAB_DEFS))))
TEX_INIT_RUN = 	1

# build
INFO_TARGETS +=	textabinfo
PRE_COMP_DEPS +=$(TEX_TAB_STYS)


.PHONY:		textabinfo
textabinfo:
		@echo "tex-tab-defs: $(TEX_TAB_DEFS)"
		@echo "tex-tab-stys: $(TEX_TAB_STYS)"

%-tab.sty:	$(TEX_TAB_DIR)/$(@F) $(MTARG_FILE)
		$(TEX_TAB_BIN) $(TEX_TAB_DIR)/$(*F).json $(@D)/$(*F)-tab.sty
