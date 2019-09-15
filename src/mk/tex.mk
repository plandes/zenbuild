# latex document creation make file
# created: 01/27/2011

## stuff to include in a makefile.in
GRAF_BIN ?=	$(BUILD_BIN_DIR)/exportgraffle.scpt
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

# package
PKG_DIR ?=	$(MTARG)/pkg
PKG_FINAL_DIR ?= $(PKG_DIR)/$(FINAL_NAME)
ADD_CLEAN_ALL += $(PKG_DIR)

# install/distribution
INSTALL_DIR ?=	$(HOME)/Desktop

# export
EXPORT_DIR ?=	$(MTARG)/export

# paths
VEC_DIR ?=	$(abspath ../vec)
IMG_DIR ?=	$(abspath ../img)
GRAFFLE_DIR ?=	$(abspath ../graffle)

# file deps
VECEPS=		$(addprefix $(LAT_COMP_PATH)/,$(notdir $(wildcard $(VEC_DIR)/*.eps)))
VECPDF=		$(addprefix $(LAT_COMP_PATH)/,$(notdir $(wildcard $(VEC_DIR)/*.pdf)))
IMAGES=		$(addprefix $(LAT_COMP_PATH)/,$(notdir $(wildcard $(IMG_DIR)/*)))
GRAFFLES=	$(addprefix $(LAT_COMP_PATH)/,$(notdir $(wildcard $(GRAFFLE_DIR)/*)))

# files
TEX_FILE=	$(LAT_COMP_PATH)/$(TEX).tex
PDF_FILE=	$(LAT_COMP_PATH)/$(TEX).pdf
MTARG_FILE=	$(LAT_COMP_PATH)/mtarg.txt
PRERUN_FILE=	$(LAT_COMP_PATH)/prerun.txt

# dependencies
PRE_COMP_DEPS +=$(VECEPS) $(VECPDF) $(IMAGES) $(GRAFFLES)
COMP_DEPS +=	$(MTARG_FILE) $(TEX_FILE) $(PRE_COMP_DEPS) $(PRERUN_FILE)

# compiles faster in Emacs avoiding fontification of verbose output
QUIET ?=	> /dev/null

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
		@echo "t-path: $(TIPATH)"
		@echo "vec-paths: $(VECEPS)"
		@echo "pdf-paths: $(VECPDF)"
		@echo "pkg-final-dir: $(PKG_FINAL_DIR)"
		@echo "graffles: $(GRAFFLES)"
		@echo "biber-file: $(BBL_FILE)"
		@echo "comp-deps: $(COMP_DEPS)"

# shortgap for dependency marker (with the exception of the .tex file) for now
$(MTARG_FILE):
		mkdir -p $(LAT_COMP_PATH)
		date >> $(MTARG_FILE)

# compile all OmniGraffle files
%.graffle:	$(MTARG_FILE)
		cp -r $(GRAFFLE_DIR)/$(@F) $@
		osascript $(GRAF_BIN) $@ $(LAT_COMP_PATH)

# copy over all vector .eps static files
%.eps:		$(VEC_DIR)/$(@F) $(MTARG_FILE)
		cp $(VEC_DIR)/$(@F) $@

# copy over all vector .pdf static files
%.pdf:		$(VEC_DIR)/$(@F) $(MTARG_FILE)
		cp $(VEC_DIR)/$(@F) $@

# copy over all raster .png static files
%.png:
		@cp $(IMG_DIR)/$(@F) $@

# copy over all raster .jpg static files
%.jpg:
		@cp $(IMG_DIR)/$(@F) $@

# recompile even when editing .sty files (make proper dependencies?)
.PHONY:		force
texforce:	$(COMP_DEPS)
		( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )

# force recompile and snow
.PHONY:		forceshow
texforceshow:	force texshowpdf

# run latex before resolving module targets (see tex-bib*.mk, tex-index.mk)
$(PRERUN_FILE):
		@echo "init run: $(TEX_INIT_RUN)"
		@if [ ! -z "$(TEX_INIT_RUN)" ] ; then \
			echo "starting latex pre-start run..." ; \
			echo $(LATEX_BIN) $(TEX).tex $(QUIET) ; \
			( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex $(QUIET) ) ; \
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
		( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )
		@if [ ! -z "$(SECOND_RUN)" ] ; then \
			echo "starting latex compile second run..." ; \
			( cd $(LAT_COMP_PATH) ; $(LATEX_BIN) $(TEX).tex $(QUIET) ) ; \
		fi

# final version: compile twice for refs and bibliography
.PHONY:		texfinal
texfinal:
		make SECOND_RUN=1 texpdf

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
		cp $(wildcard $(LAT_COMP_PATH)/*.eps $(LAT_COMP_PATH)/*.png $(LAT_COMP_PATH)/*.jpg $(LAT_COMP_PATH)/*.gif) $(EXPORT_DIR)
		cp $(wildcard $(addsuffix /*,$(TIPATH))) $(EXPORT_DIR)
		cp $(BUILD_SRC_DIR)/template/tex-export-makefile $(EXPORT_DIR)/makefile
		if [ ! -z "$(BIBER)" ] ; then \
			touch $(EXPORT_DIR)/zenbiber ; \
		fi

# create the presentation form of the slides
.PHONY:		texpresentpdf
texpresentpdf:
		make PDFLAT_ARGS="'\def\ispresentation{1} \input{$(TEX).tex}'" \
			SECOND_RUN=1 texpdf

# create a zip file with the only the PDF as its contents
.PHONY:		texpackage
texpackage:	$(PKG_FINAL_DIR)

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

.PHONY:		texinstall
texinstall:	texpackage
		( cd $(PKG_DIR) ; zip -r $(FINAL_NAME).zip $(FINAL_NAME) )
		cp $(PKG_DIR)/$(FINAL_NAME)/* $(PKG_DIR)/$(FINAL_NAME).zip $(INSTALL_DIR)
