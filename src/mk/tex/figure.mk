#@meta {author: "Paul Landes"}
#@meta {desc: "creating latex figures from CSV files", date: "2025-06-13"}
#@meta {requires: "python/build.mk", order: "before"}
#
# To use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex/figure
#
# For now, ther is one <table name>-figure.yml file with 'table name' matching
# the table name in the configuration file.  If this pattern isn't followed,
# the GNU make target file name matching won't work.


## Module
#
# where YAML figure definitions live
TEX_FIG_DIR ?=		$(TEX_CONF_DIR)
# all figure definitions
TEX_FIG_DEFS +=		$(wildcard $(TEX_FIG_DIR)/*-figure.yml)
TEX_FIG_EPS =		$(addprefix $(TEX_LAT_PATH)/,$(notdir $(patsubst %-figure.yml,%.eps,$(TEX_FIG_DEFS))))
TEX_FIG_SVG =		$(addprefix $(TEX_LAT_PATH)/,$(notdir $(patsubst %-figure.yml,%.svg,$(TEX_FIG_DEFS))))


## Build
#
INFO_TARGETS +=		texfiginfo
TEX_PRE_COMP_DEPS +=	$(TEX_FIG_EPS)


## Includes
#
include $(BUILD_MK_DIR)/tex/datdesc.mk


## Targets
#
# build info
.PHONY:		texfiginfo
texfiginfo:
		@echo "tax-fig-defs: $(TEX_FIG_DEFS)"
		@echo "tax-fig-eps: $(TEX_FIG_EPS)"
		@echo "tex-tab-dir: $(TEX_FIG_DIR)"

# run the program to generate the figures
.PHONY:		texfig
texfig:
		@echo "creating $(TEX_FIG_EPS) in $(TEX_DATDESC_WD)"
		@$(call datdesc,figure -e eps $(TEX_FIG_DIR) $(TEX_LAT_PATH))

# convenience: run the program, compile the PDF, then display it
.PHONY:		texfigshow
texfigshow:	texfig show

# generate a new LaTeX .sty file for every *-figure.yml found
%.eps:		$(TEX_FIG_DIR)/$(@F) $(TEX_MTARG_FILE)
		make texfig

# output a vector graphics files, and then display them
.PHONY:		texfigrender
texfigrender:
		@$(call datdesc,figure -e svg $(TEX_FIG_DIR) $(TEX_LAT_PATH))
		$(RENDER_BIN) $(TEX_FIG_SVG)
