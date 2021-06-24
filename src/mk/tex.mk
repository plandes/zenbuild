# latex document creation make file
# created: 01/27/2011

## stuff to include in a makefile.in
SHOWPREV_BIN ?=	$(BUILD_BIN_DIR)/showpreview.scpt
PRESENT_BIN ?=	/Applications/Presentation.app/Contents/MacOS/presentation.py
PYTHON_BIN ?=	/usr/bin/python

## everything else shouldn't need modifying paths
nullstr=
space=		$(nullstr) $(nullstring)
TIPATH +=	$(BUILD_SRC_DIR)/sty $(abspath ./sty)
LAT_COMP_PATH=	$(MTARG)/lat
TIPATH_MTARG=	$(LAT_COMP_PATH) $(TIPATH)
TIPATHSTR=	$(subst $(space),:,$(TIPATH_MTARG))
# trailing colon needed
TPATH=		TEXINPUTS=$(TIPATHSTR):
PDFLAT_ARGS +=
LATEX_BIN ?=	$(TPATH) pdflatex $(PDFLAT_ARGS) -output-directory $(LAT_COMP_PATH)

# install/distribution
INSTALL_DIR ?=	$(HOME)/Desktop
INSTALL_PDF ?=	$(INSTALL_DIR)/$(FINAL_NAME).pdf
INSTALL_ZIP ?=	$(INSTALL_DIR)/$(FINAL_NAME).zip

# paths
TEX_CACHE_DIR ?= $(abspath ../cache)
TEX_IMG_DIR ?=	$(abspath ../image)
TEX_IMGC_DIR ?=	$(TEX_CACHE_DIR)/image
TEX_CONF_DIR ?=	$(abspath ../config)

# package
PKG_DIR ?=	$(MTARG)/pkg
PKG_FINAL_DIR ?= $(PKG_DIR)/$(FINAL_NAME)
TEX_PKG_ADD +=
ADD_CLEAN_ALL += $(PKG_DIR) $(INSTALL_PDF) $(INSTALL_ZIP) $(TEX_CACHE_DIR)

# export
EXPORT_DIR ?=	$(MTARG)/export

# file deps
TEX_IMG_EPS=	$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.eps)))
TEX_IMG_PNG=	$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.png)))
TEX_IMG_JPG=	$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.jpg)))
TEX_IMAGES=	$(TEX_IMG_EPS) $(TEX_IMG_PNG) $(TEX_IMG_JPG)

# files
TEX_FILE=	$(LAT_COMP_PATH)/$(TEX).tex
PDF_FILE=	$(LAT_COMP_PATH)/$(TEX).pdf
MTARG_FILE=	$(LAT_COMP_PATH)/mtarg.txt
PRERUN_FILE=	$(LAT_COMP_PATH)/prerun.txt

# dependencies
PRE_COMP_DEPS +=$(TEX_IMAGES)
COMP_DEPS +=	$(MTARG_FILE) $(TEX_FILE) $(PRE_COMP_DEPS) $(PRERUN_FILE)

# control verbosity
TEX_QUIET ?=	1
ifeq ($(TEX_QUIET),1)
# https://tex.stackexchange.com/questions/1191/reducing-the-console-output-of-latex
PDFLAT_ARGS +=	-interaction batchmode
# no output at all
QUIET ?=	> /dev/null
endif

# default position of Preview.app
PREV_POS ?=	{1500, 0}
PREV_SIZE ?=	{1400, 1600}

# invokes a pre run
TEX_INIT_RUN =
# build
INFO_TARGETS +=	texinfo

## targets
.PHONY:	texinfo
texinfo:
		@echo "tex-file: $(TEX).tex"
		@echo "tipath: $(TIPATH)"
		@echo "vec-paths: $(TEX_VEC_PS)"
		@echo "pdf-paths: $(TEX_VEC_PDF)"
		@echo "pkg-final-dir: $(PKG_FINAL_DIR)"
		@echo "biber-file: $(BBL_FILE)"
		@echo "comp-deps: $(COMP_DEPS)"
		@echo "pdf-file: $(PDF_FILE)"

# shortgap for dependency marker (with the exception of the .tex file) for now
$(MTARG_FILE):
		mkdir -p $(LAT_COMP_PATH)
		mkdir -p $(TEX_IMGC_DIR)
		date >> $(MTARG_FILE)

# copy over all vector .eps static files
%.eps:		$(TEX_IMG_DIR)/$(@F) $(MTARG_FILE)
		cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all vector .pdf static files
%.pdf:		$(TEX_IMG_DIR)/$(@F) $(MTARG_FILE)
		cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all raster .png static files
%.png:
		@cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all raster .jpg static files
%.jpg:
		@cp $(TEX_IMG_DIR)/$(@F) $@

# recompile even when editing .sty files (make proper dependencies?)
.PHONY:		force
texforce:	$(COMP_DEPS)
		( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex )

# force recompile and snow
.PHONY:		forceshow
texforceshow:	force texshowpdf

# run three times when running from scratch and indicated to do so with
# SECOND_RUN_INIT, otherwise reference links are question marks and a manual
# forced run would otherwise be necessary
ifeq ($(SECOND_RUN_INIT),1)
  ifneq (,$(PRERUN_FILE))
    SECOND_RUN=1
  endif
endif

# run latex before resolving module targets (see tex-bib*.mk, tex-index.mk)
$(PRERUN_FILE):
		@echo "init run: $(TEX_INIT_RUN)"
		@if [ ! -z "$(TEX_INIT_RUN)" ] ; then \
			echo "copying images $(TEX_IMGC_DIR) -> $(LAT_COMP_PATH)" ; \
			cp $(TEX_IMGC_DIR)/* $(LAT_COMP_PATH) ; \
			echo "starting latex pre-start run..." ; \
			echo $(LATEX_BIN) $(TEX).tex ; \
			( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex ) ; \
			date >> $(PRERUN_FILE) ; \
		fi

# top level dependency (add sty files as dependencies later?)
$(TEX_FILE):	$(TEX).tex
		cp $(TEX).tex $(LAT_COMP_PATH)

# build the PDF
.PHONY:		texpdf
texpdf:		$(PDF_FILE)

# should be able to put $(COMP_DEPS) as a dependency.  However, given the *.mk
# file proccessing order, it completely skips the module make files
$(PDF_FILE):	$(COMP_DEPS)
		@echo "generating $(PDF_FILE)"
		make $(COMP_DEPS)
		@echo "latex first compile..."
		( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex )
		@if [ ! -z "$(SECOND_RUN)" ] ; then \
			echo "starting latex compile second run..." ; \
			( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex ) ; \
		fi

# "debug" the compilation process by not adding quiet flags to pdflatex
.PHONY:		texdebug
texdebug:
		make TEX_QUIET=0 texpdf

# final version: compile twice for refs and bibliography
.PHONY:		texfinal
texfinal:
		make PDFLAT_ARGS="'\def\isfinal{1} \input{$(TEX).tex}'" \
			SECOND_RUN=1 texpdf

# compile and display the file using a simple open (MacOS or alias out)
.PHONY:		texshowpdf
texshowpdf:	texpdf
		open $(PDF_FILE)

# a one pass compile and show (will flub refs and bibliography)
.PHONY:		texshowquick
texshowquick:
		make PROJ_MODULES= SECOND_RUN= texshowpdf

# compile the final version and show in Preview
.PHONY:		texfinalshow
texfinalshow:	texfinal texshowpdf

# show and reposition the Preview.app window (under MacOS)
.PHONY:		texreposition
texreposition:	texpdf
		open $(PDF_FILE)
		osascript $(SHOWPREV_BIN) $(PDF_FILE) $(PREV_LOC)

# create a no dependency (from zenbuild) directory with files to recreate PDF
.PHONY:		texexport
texexport:	texpdf
		mkdir -p $(EXPORT_DIR)
		cp $(wildcard $(TEX).tex $(BIB_FILE) $(BBL_FILE)) $(EXPORT_DIR)
		cp $(wildcard $(LAT_COMP_PATH)/*.eps $(LAT_COMP_PATH)/*.png \
			$(LAT_COMP_PATH)/*.jpg $(LAT_COMP_PATH)/*.gif \
			$(LAT_COMP_PATH)/*.sty) $(EXPORT_DIR)
		cp $(wildcard $(addsuffix /*,$(TIPATH))) $(EXPORT_DIR)
		cp $(BUILD_SRC_DIR)/template/tex/export-makefile $(EXPORT_DIR)/makefile
		if [ ! -z "$(BIBER)" ] ; then \
			touch $(EXPORT_DIR)/zenbiber ; \
		fi
		@echo "exported stand-alone build to $(EXPORT_DIR)"

# create the presentation form of the slides
.PHONY:		texpresentpdf
texpresentpdf:
		make PDFLAT_ARGS="'\def\ispresentation{1} \input{$(TEX).tex}'" \
			SECOND_RUN=1 texpdf

# create a zip file with the only the PDF as its contents
.PHONY:		texpackage
texpackage:	$(PKG_FINAL_DIR) $(TEX_PKG_ADD)

# package directory target generates both slides versions or default paper/report
$(PKG_FINAL_DIR):
		mkdir -p $(PKG_FINAL_DIR)
		make texfinal
		@if [ -z "$(SLIDES)" ] ; then \
			cp $(PDF_FILE) $(PKG_FINAL_DIR)/$(FINAL_NAME).pdf ; \
		else \
			cp $(PDF_FILE) $(PKG_FINAL_DIR)/$(FINAL_NAME)-slides.pdf ; \
			rm -rf $(LAT_COMP_PATH) ; \
			make texpresentpdf ; \
			cp $(PDF_FILE) $(PKG_FINAL_DIR)/$(FINAL_NAME)-presenetation.pdf ; \
		fi

# present a slide deck
.PHONY:		texpresent
texpresent:	texpackage
		@echo "NOTE!: uncheck mirror mode: Sys Prefs > Display > Arragenemnt"
		$(PYTHON_BIN) $(PRESENT_BIN) $(PKG_FINAL_DIR)/$(FINAL_NAME)-presenetation.pdf

# create final version, compress if mulitple files, then cpoy to install
# location
.PHONY:		texinstall
texinstall:	texpackage
		@if [ `ls $(PKG_DIR)/$(FINAL_NAME) | wc -l` -gt 1 ] ; then \
			echo "installing zip of all resources..." ; \
			( cd $(PKG_DIR) ; zip -r $(FINAL_NAME).zip $(FINAL_NAME) ) ; \
			cp $(PKG_DIR)/$(FINAL_NAME).zip $(INSTALL_ZIP) ; \
		else \
			echo "installing just PDF" ; \
			cp $(PKG_DIR)/$(FINAL_NAME)/$(FINAL_NAME).pdf $(INSTALL_PDF) ; \
		fi
