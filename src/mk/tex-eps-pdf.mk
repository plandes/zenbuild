# make module for converting eps to pdf files; requires CLI `convert'

# Note that this is usually handled by pdflatex.  However, in some cases
# (i.e. using an \includegraphics in a tabularx).  See:
#   https://tex.stackexchange.com/questions/352130/epstopdf-does-not-find-figure-within-tabularx-environment
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-eps-pdf
# 2019-11-01


## build

# all .eps -> .pdf
TEX_IMG_PDF=	$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(patsubst %.eps,%.pdf,$(wildcard $(TEX_IMG_DIR)/*.eps))))
# add PDF dependencies from 
TEX_PRE_COMP_DEPS +=$(TEX_IMG_PDF)
# information target
INFO_TARGETS +=	tex-eps-pdf-info


## targets
.PHONY:	tex-eps-pdf-info
tex-eps-pdf-info:
		@echo "pdf: $(TEX_IMG_PDF)"

# copy over all vector .pdf static files
%.pdf:		$(TEX_IMG_DIR)/$(@F) $(TEX_MTARG_FILE)
		$(eval DST_EPS=$(patsubst %.pdf,%.eps,$(TEX_IMG_DIR)/$(@F)))
		@echo "$(DST_EPS) -> $@"
		convert $(DST_EPS) $@
