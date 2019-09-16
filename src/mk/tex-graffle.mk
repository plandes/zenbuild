# make module for converting OmniGraffle diagrams to Encapsulated Postscript
# files that are embedded in the final PDF.
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-graffle
# 9/15/2019

# script to generate EPS from OmniGraffle files
TEX_GRF_BIN ?=	$(BUILD_BIN_DIR)/exportgraffle.scpt
TEX_GRF_DIR ?=	$(abspath ../graffle)
TEX_GRF_FILES=	$(addprefix $(LAT_COMP_PATH)/,$(notdir $(wildcard $(TEX_GRF_DIR)/*)))

# build
INFO_TARGETS +=	texgraffleinfo
PRE_COMP_DEPS +=$(TEX_GRF_FILES)


.PHONY:		texgraffleinfo
texgraffleinfo:
		@echo "tex-grf-files: $(TEX_GRF_FILES)"

# compile all OmniGraffle files
%.graffle:	$(MTARG_FILE)
		cp -r $(TEX_GRF_DIR)/$(@F) $@
		osascript $(TEX_GRF_BIN) $@ $(LAT_COMP_PATH)
