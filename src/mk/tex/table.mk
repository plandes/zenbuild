#@meta {author: "Paul Landes"}
#@meta {desc: "creating latex tables from CSV files", date: "2025-06-13"}
#@meta {requires: "python/build.mk", order: "before"}
#@meta {install: "PROJ_LOCAL_MODULES += tex/table"}


## Module
#
# where YAML table definitions live
TEX_TAB_DIR ?=		$(TEX_CONF_DIR)
# all table definitions
TEX_TAB_DEFS +=		$(wildcard $(TEX_TAB_DIR)/*-table.yml)
TEX_TAB_STYS =		$(addprefix $(TEX_LAT_PATH)/,$(notdir $(patsubst %.yml,%.sty,$(TEX_TAB_DEFS))))


## Build
#
INFO_TARGETS +=		textabinfo
TEX_PRE_COMP_DEPS +=	$(TEX_TAB_STYS)


## Includes
#
include $(BUILD_MK_DIR)/tex/datdesc.mk


## Targets
#
# build info
.PHONY:		textabinfo
textabinfo:
		@echo "tex-tab-defs: $(TEX_TAB_DEFS)"
		@echo "tex-tab-stys: $(TEX_TAB_STYS)"
		@echo "tex-tab-dir: $(TEX_TAB_DIR)"

# run the program to generate the tables
.PHONY:		textab
textab:
		@echo "creating $(TEX_TAB_STYS) in $(TEX_DATDESC_WD)"
		@$(call datdesc,table $(TEX_TAB_DIR) $(TEX_LAT_PATH))

# convenience: run the program, compile the PDF, then display it
.PHONY:		textabshow
textabshow:	textab show

# generate a new LaTeX .sty file for every *-table.yml found
%-table.sty:	$(TEX_TAB_DIR)/$(@F) $(TEX_MTARG_FILE)
		@$(MAKE) --no-print-directory textab
