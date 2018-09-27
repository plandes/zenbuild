# latex document creation make file
# created: 01/27/2011

## top level paths
#TEXLIBDIR ?=	$(BUILD_HOME_DIR)/lib

## stuff to include in a makefile.in
GRAF_BIN=	$(BUILD_BIN_DIR)/exportgraffle.scpt

## everything else shouldn't need modifying paths
nullstr=
space=		$(nullstr) $(nullstring)
TIPATH +=	$(BUILD_SRC_DIR)/sty $(abspath ./sty)
TIPATH_MTARG=	$(MTARG) $(TIPATH)
TIPATHSTR=	$(subst $(space),:,$(TIPATH_MTARG))
# trailing colon needed
TPATH=		TEXINPUTS=$(TIPATHSTR):
LATEX_BIN ?=	$(TPATH) pdflatex -output-directory $(MTARG)

# export
EXPORT_DIR ?=	$(MTARG)/export

# paths
VEC_DIR=	$(abspath ../vec)
IMG_DIR=	$(abspath ../img)
GRAFFLE_DIR=	$(abspath ../graffle)

# file deps
VECEPS=		$(addprefix $(MTARG)/,$(notdir $(wildcard $(VEC_DIR)/*)))
IMAGES=		$(addprefix $(MTARG)/,$(notdir $(wildcard $(IMG_DIR)/*)))
GRAFFLES=	$(addprefix $(MTARG)/,$(notdir $(wildcard $(GRAFFLE_DIR)/*)))

# files
TEX_FILE=	$(MTARG)/$(TEX).tex
PDF_FILE=	$(MTARG)/$(TEX).pdf
MTARG_FILE=	$(MTARG)/mtarg.txt

# dependencies
COMP_DEPS +=	$(MTARG_FILE) $(TEX_FILE) $(VECEPS) $(IMAGES) $(GRAFFLES)
DISTDIR=	$(TEX)-$(shell date +'%y-%m-%d')
DISTZIP=	$(DISTDIR).zip

# compiles faster in Emacs avoiding fontification of verbose output
QUIET ?=	> /dev/null

# default position of Preview.app
PREV_POS ?=	{1500, 0}
PREV_SIZE ?=	{1400, 1600}

# build
INFO_TARGETS +=	latexinfo


## targets
.PHONY:	latexinfo
latexinfo:
		@echo "tex-file: $(TEX).tex"
		@echo "t-path: $(TIPATH)"
		@echo "vec-paths: $(VECEPS)"
		@echo "graffles: $(GRAFFLES)"
		@echo "biber-file: $(BBL_FILE)"
		@echo "deps: $(COMP_DEPS)"

$(MTARG_FILE):
		mkdir -p $(MTARG)
		date >> $(MTARG_FILE)

%.graffle:	$(MTARG_FILE)
		cp -r $(GRAFFLE_DIR)/$(@F) $@
		osascript $(GRAF_BIN) $@ $(MTARG)

%.eps:		$(VEC_DIR)/$(@F) $(MTARG_FILE)
		cp $(VEC_DIR)/$(@F) $@

%.png:
		@cp $(IMG_DIR)/$(@F) $@

%.jpg:
		@cp $(IMG_DIR)/$(@F) $@

.PHONY:		imagedim
imagedim:
		@for i in $(IMG_DIR)/* ; do \
			$(BIN_DIR)/rastgraphics $$i ; \
		done

.PHONY:		force
force:		$(COMP_DEPS)
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )

.PHONY:		forceshow
forceshow:	force showpdf

$(TEX_FILE):	$(TEX).tex
		cp $(TEX).tex $(MTARG)

.PHONY:		compdeps
compdeps:	$(COMP_DEPS)

.PHONY:		pdf
pdf:		$(PDF_FILE)

# should be able to put $(COMP_DEPS) as a dependency.  However, given the *.mk
# file proccessing order, it completely skips the module make files
$(PDF_FILE):	$(COMP_DEPS)
		make $(COMP_DEPS)
		@echo "latex first compile..."
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
		@if [ ! -z "$(SECOND_RUN)" ] ; then \
			echo "starting latex compile second run..." ; \
			( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) ) ; \
		fi
		@if [ ! -z "$(FINAL_PDF_NAME)" ] ; then \
			echo "copy $(PDF_FILE) -> $(FINAL_PDF_NAME)..." ; \
			cp $(PDF_FILE) "$(FINAL_PDF_NAME)" ; \
		fi

.PHONY:		dist
dist:		$(DISTZIP)

$(DISTDIR):	$(PDF_FILE)
		mkdir -p $(DISTDIR)
		cp $(PDF_FILE) $(DISTDIR)

$(DISTZIP):	$(DISTDIR) $(PDF_FILE)
		zip -r $(DISTZIP) $(DISTDIR)

.PHONY:		showpdf
showpdf:	$(PDF_FILE)
		open $(PDF_FILE)

.PHONY:		reposition
reposition:	showpdf
		osascript -e 'tell application "System Events" to set position of first window of application process "Preview" to $(PREV_POS)'
		osascript -e 'tell application "System Events" to set size of first window of application process "Preview" to $(PREV_SIZE)'
		osascript -e 'tell application "Emacs" to activate'

.PHONY:		export
export:		pdf
		mkdir -p $(EXPORT_DIR)
		cp $(wildcard $(TEX).tex $(BIB_FILE) $(BBL_FILE)) $(EXPORT_DIR)
		cp $(wildcard $(MTARG)/*.eps $(MTARG)/*.png $(MTARG)/*.jpg $(MTARG)/*.gif) $(EXPORT_DIR)
		cp $(wildcard $(addsuffix /*,$(TIPATH))) $(EXPORT_DIR)
		cp $(BUILD_SRC_DIR)/template/tex-export-makefile $(EXPORT_DIR)/makefile

.PHONY:		showexportpdf
showexportpdf:	export
		make -C $(EXPORT_DIR)
		open $(EXPORT_DIR)/$(TEX).pdf
