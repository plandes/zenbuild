#@meta {author: "Paul Landes"}
#@meta {desc: "copying image (*.eps) files when graffle files", date: "2025-09-05"}
#@meta {install: "PROJ_MODULES += tex/images"}


## Module
#
TEX_IMGS_SRC =		$(wildcard $(TEX_IMG_DIR)/*.eps) \
			$(wildcard $(TEX_IMG_DIR)/*.png) \
			$(wildcard $(TEX_IMG_DIR)/*.jpg)
TEX_PRE_COMP_DEPS +=	teximagescopy


## Build
#
INFO_TARGETS +=		teximagesinfo


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
