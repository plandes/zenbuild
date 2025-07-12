# make module for converting OmniGraffle diagrams to Encapsulated Postscript
# files that are embedded in the final PDF.
#
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-graffle


# script to generate EPS from OmniGraffle files
TEX_GRF_BIN ?=	$(BUILD_BIN_DIR)/exportgraffle.scpt
TEX_GRF_DIR ?=	$(TEX_IMG_DIR)
TEX_GRF_FILES=	$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_GRF_DIR)/*.graffle)))

# build
INFO_TARGETS +=	texgraffleinfo
TEX_PRE_COMP_DEPS +=texgraffleimgdir $(TEX_GRF_FILES)


.PHONY:		texgraffleinfo
texgraffleinfo:
		@echo "tex-grf-files: $(TEX_GRF_FILES)"

.PHONY:		texgraffleimgdir
texgraffleimgdir:
		@mkdir -p $(TEX_IMGC_DIR)

# compile all OmniGraffle files
%.graffle:	$(TEX_MTARG_FILE)
		@echo "generating images from OmniGraffle file $@..."
		cp -r $(TEX_GRF_DIR)/$(@F) $@
		osascript $(TEX_GRF_BIN) $@ $(TEX_IMGC_DIR)
