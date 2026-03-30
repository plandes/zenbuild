#@meta {author: "Paul Landes"}
#@meta {desc: "copying image (*.eps) files when graffle files", date: "2025-09-05"}
#@meta {install: "PROJ_MODULES += tex/images"}


## Module
#
TEX_IMGS_SRC =		$(wildcard $(TEX_IMG_DIR)/*.eps) \
			$(wildcard $(TEX_IMG_DIR)/*.png) \
			$(wildcard $(TEX_IMG_DIR)/*.jpg)
#TEX_IMGS_DST +=		$(patsubst $(TEX_IMG_DIR)/%,$(TEX_LAT_PATH)/%,$(TEX_IMGS_SRC))
#TEX_PRE_COMP_DEPS +=	$(TEX_IMGS_DST)
TEX_PRE_COMP_DEPS +=	teximagescopy


## Build
#
#TEX_INIT_RUN =		1
INFO_TARGETS +=		teximagesinfo


# $(foreach s,$(TEX_IMGS_SRC), \
#   $(eval $(patsubst $(TEX_IMG_DIR)/%,$(TEX_LAT_PATH)/%,$(s)): $(s)) \
# )


## Targets
#
.PHONY:			teximagesinfo
teximagesinfo:
			@echo "tex-images-src: $(TEX_IMGS_SRC)"
			@echo "tex-images-dst: $(TEX_IMGS_DST)"

.PHONY:			teximagescopy
teximagescopy:
			@for f in $(TEX_IMGS_SRC); do \
				dst="$(TEX_LAT_PATH)/$${f##*/}"; \
				echo "copy image: $$f -> $$dst"; \
				install -m 644 "$$f" "$$dst"; \
			done


# $(TEX_LAT_PATH)/%.eps: $(TEX_IMG_DIR)/%.eps
# 	@echo "copy image: $< $@"
# 	cp $< $@

# $(TEX_LAT_PATH)/%.png: $(TEX_IMG_DIR)/%.png
# 	@echo "copy image: $< $@"
# 	cp $< $@

# $(TEX_LAT_PATH)/%.jpg: $(TEX_IMG_DIR)/%.jpg
# 	@echo "copy image: $< $@"
# 	cp $< $@
