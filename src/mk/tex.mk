# latex document creation make file
# created: 01/27/2011

## to include in a makefile.in
TEX_SHOWPREV_BIN ?=	$(BUILD_BIN_DIR)/showpreview.scpt
TEX_PRESENT_BIN ?=	/Applications/Presentation.app/Contents/MacOS/presentation.py
TEX_PYTHON_BIN ?=	/usr/bin/python

## everything else shouldn't need modifying paths
TEX_nullstr=
TEX_space=		$(TEX_nullstr) $(TEX_nullstr)
TEX_PATH +=		$(BUILD_SRC_DIR)/sty $(abspath ./sty)
TEX_LAT_PATH =		$(MTARG)/lat
TEX_PATH_MTARG =	$(TEX_LAT_PATH) $(TEX_PATH)
TEX_PATHSTR =		$(subst $(TEX_space),:,$(TEX_PATH_MTARG))
# trailing colon needed
TEX_TPATH =		TEXINPUTS=$(TEX_PATHSTR):
TEX_PDFLAT_ARGS +=
TEX_LATEX_CMD ?=	$(TEX_TPATH) pdflatex -output-directory $(TEX_LAT_PATH) $(TEX_PDFLAT_ARGS)

# install/distribution
TEX_INSTALL_DIR ?=	$(HOME)/Desktop
TEX_INSTALL_PDF ?=	$(TEX_INSTALL_DIR)/$(FINAL_NAME).pdf
TEX_INSTALL_ZIP ?=	$(TEX_INSTALL_DIR)/$(FINAL_NAME).zip

# paths
TEX_CACHE_DIR ?= 	$(abspath ../cache)
TEX_IMG_DIR ?=		$(abspath ../image)
TEX_IMGC_DIR ?=		$(TEX_CACHE_DIR)/image
TEX_CONF_DIR ?=		$(abspath ../config)

# package
TEX_PKG_DIR ?=		$(MTARG)/pkg
TEX_PKG_FINAL_DIR ?= 	$(TEX_PKG_DIR)/$(FINAL_NAME)
TEX_PKG_ADD +=

# file deps
TEX_IMG_EPS =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.eps)))
TEX_IMG_PNG =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.png)))
TEX_IMG_JPG =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.jpg)))
TEX_IMAGES =		$(TEX_IMG_EPS) $(TEX_IMG_PNG) $(TEX_IMG_JPG)

# files
TEX_LATEX_FILE =	$(TEX_LAT_PATH)/$(TEX).tex
TEX_PDF_FILE =		$(TEX_LAT_PATH)/$(TEX).pdf
TEX_MTARG_FILE =	$(TEX_LAT_PATH)/mtarg.txt
TEX_PRERUN_FILE =	$(TEX_LAT_PATH)/prerun.txt

# dependencies
TEX_PRE_COMP_DEPS +=	$(TEX_IMAGES)
COMP_DEPS +=		$(TEX_MTARG_FILE) $(TEX_LATEX_FILE) $(TEX_PRE_COMP_DEPS) $(TEX_PRERUN_FILE)

# control verbosity
TEX_QUIET ?=		1
ifeq ($(TEX_QUIET),1)
# https://tex.stackexchange.com/questions/1191/reducing-the-console-output-of-latex
TEX_PDFLAT_ARGS +=	-interaction batchmode
# no output at all
TEX_QUIET_REDIR ?=	> /dev/null
endif

# default init commands
TEX_LATEX_INIT_CMD ?=	\newif\ifisfinal
TEX_LATEX_INIT_ADD ?=
TEX_PDFLAT_ARGS +=	'$(TEX_LATEX_INIT_CMD) $(TEX_LATEX_INIT_ADD) \input{$(TEX).tex}'

# default position of Preview.app
TEX_PREV_POS ?=		{1500, 0}
TEX_PREV_SIZE ?=	{1400, 1600}

# invokes a pre run
TEX_INIT_RUN =

# number of times to run when creating final (i.e. installed) PDF
TEX_FINAL_RUNS ?= 2

# build
ADD_CLEAN_ALL += $(TEX_PKG_DIR) $(TEX_INSTALL_PDF) $(TEX_INSTALL_ZIP) $(TEX_CACHE_DIR)
INFO_TARGETS +=	texinfo


# run three times when running from scratch and indicated to do so with
# SECOND_RUN_INIT, otherwise reference links are question marks and a manual
# forced run would otherwise be necessary
ifeq ($(SECOND_RUN_INIT),1)
  ifneq (,$(TEX_PRERUN_FILE))
    SECOND_RUN=1
  endif
endif


## targets
.PHONY:	texinfo
texinfo:
		@echo "tex-file: $(TEX).tex"
		@echo "tipath: $(TEX_PATH)"
		@echo "vec-paths: $(TEX_VEC_PS)"
		@echo "pdf-paths: $(TEX_VEC_PDF)"
		@echo "pkg-final-dir: $(TEX_PKG_FINAL_DIR)"
		@echo "biber-file: $(BBL_FILE)"
		@echo "comp-deps: $(COMP_DEPS)"
		@echo "pdf-file: $(TEX_PDF_FILE)"

# shortgap for dependency marker (with the exception of the .tex file) for now
$(TEX_MTARG_FILE):
		mkdir -p $(TEX_LAT_PATH)
		mkdir -p $(TEX_IMGC_DIR)
		date >> $(TEX_MTARG_FILE)

# copy over all vector .eps static files
%.eps:		$(TEX_IMG_DIR)/$(@F) $(TEX_MTARG_FILE)
		cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all vector .pdf static files
%.pdf:		$(TEX_IMG_DIR)/$(@F) $(TEX_MTARG_FILE)
		cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all raster .png static files
%.png:
		@cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all raster .jpg static files
%.jpg:
		@cp $(TEX_IMG_DIR)/$(@F) $@

.PHONY:		texversion
texversion:
		( cd /Library/TeX/Root && pwd -P )

# recompile even when editing .sty files (make proper dependencies?)
.PHONY:		texforce
texforce:	$(COMP_DEPS)
		@echo "forcing make"
		make $(COMP_DEPS)
		( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) )

# force recompile and snow
.PHONY:		forceshow
texforceshow:	force texshowpdf

# run latex before resolving module targets (see tex-bib*.mk, tex-index.mk)
$(TEX_PRERUN_FILE):
		@echo "init run: $(TEX_INIT_RUN)"
		@if [ ! -z "$(TEX_INIT_RUN)" ] ; then \
			echo "copying images $(TEX_IMGC_DIR) -> $(TEX_LAT_PATH)" ; \
			cp $(TEX_IMGC_DIR)/* $(TEX_LAT_PATH) ; \
			echo "starting latex pre-start run..." ; \
			echo $(TEX_LATEX_CMD) ; \
			( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) ) ; \
			if [ $$? != 0 ] ; then \
				exit 1 ; \
			fi ; \
			date >> $(TEX_PRERUN_FILE) ; \
		fi

# top level dependency (add sty files as dependencies later?)
$(TEX_LATEX_FILE):	$(TEX).tex
		cp $(TEX).tex $(TEX_LAT_PATH)

# should be able to put $(COMP_DEPS) as a dependency.  However, given the *.mk
# file proccessing order, it completely skips the module make files
$(TEX_PDF_FILE):	$(COMP_DEPS)
		@echo "generating $(TEX_PDF_FILE)"
		make $(COMP_DEPS)
		@echo "latex first compile..."
		( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) )
		@if [ ! -z "$(SECOND_RUN)" ] ; then \
			echo "starting latex compile second run..." ; \
			( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) ) ; \
		fi

# build the PDF
.PHONY:		texcompile
texcompile:	$(TEX_PDF_FILE)


# "debug" the compilation process by not adding quiet flags to pdflatex
.PHONY:		texdebug
texdebug:
		make TEX_QUIET=0 texforce

# compile and display the file using a simple open (MacOS or alias out)
.PHONY:		texshowpdf
texshowpdf:	texcompile
		open $(TEX_PDF_FILE)

# a one pass compile and show (will flub refs and bibliography)
.PHONY:		texshowquick
texshowquick:
		make PROJ_MODULES= SECOND_RUN= texshowpdf

# compile the final version and show in Preview
.PHONY:		texfinalshow
texfinalshow:	texfinal texshowpdf

# show and reposition the Preview.app window (under MacOS)
.PHONY:		texreposition
texreposition:	texcompile
		open $(TEX_PDF_FILE)
		osascript $(TEX_SHOWPREV_BIN) $(TEX_PDF_FILE) $(PREV_LOC)

# final version: compile twice for refs and bibliography
.PHONY:		texfinal
texfinal:
		@for i in `seq $(TEX_FINAL_RUNS)` ; do \
			echo "run number $$i" ; \
			make TEX_LATEX_INIT_CMD="\newif\ifisfinal\isfinaltrue" texforce ; \
			if [ $$? != 0 ] ; then \
				exit 1 ; \
			fi ; \
		done

# create the presentation form of the slides
.PHONY:		texpresentpdf
texpresentpdf:
		@for i in `seq $(TEX_FINAL_RUNS)` ; do \
			echo "run number $$i" ; \
			make TEX_LATEX_INIT_CMD="\newif\ifisfinal\isfinaltrue \def\ispresentation{1}" \
				texforce ; \
			if [ $$? != 0 ] ; then \
				exit 1 ; \
			fi ; \
		done

# create a zip file with the only the PDF as its contents
.PHONY:		texpackage
texpackage:	$(TEX_PKG_FINAL_DIR) $(TEX_PKG_ADD)

# package directory target generates both slides versions or default paper/report
$(TEX_PKG_FINAL_DIR):
		mkdir -p $(TEX_PKG_FINAL_DIR)
		make texfinal
		@if [ -z "$(TEX_SLIDES)" ] ; then \
			cp $(TEX_PDF_FILE) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME).pdf ; \
		else \
			cp $(TEX_PDF_FILE) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME)-slides.pdf ; \
			rm -rf $(TEX_LAT_PATH) ; \
			make texpresentpdf ; \
			cp $(TEX_PDF_FILE) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME)-presenetation.pdf ; \
		fi

# present a slide deck
.PHONY:		texpresent
texpresent:	texpackage
		@echo "NOTE!: uncheck mirror mode: Sys Prefs > Display > Arragenemnt"
		$(TEX_PYTHON_BIN) $(TEX_PRESENT_BIN) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME)-presenetation.pdf

# create final version, compress if mulitple files, then copy to install
# location
.PHONY:		texinstall
texinstall:	texpackage
		@if [ `ls $(TEX_PKG_DIR)/$(FINAL_NAME) | wc -l` -gt 1 ] ; then \
			echo "installing zip of all resources..." ; \
			( cd $(TEX_PKG_DIR) ; zip -r $(FINAL_NAME).zip $(FINAL_NAME) ) ; \
			cp $(TEX_PKG_DIR)/$(FINAL_NAME).zip $(TEX_INSTALL_ZIP) ; \
		else \
			echo "installing just PDF" ; \
			cp $(TEX_PKG_DIR)/$(FINAL_NAME)/$(FINAL_NAME).pdf $(TEX_INSTALL_PDF) ; \
		fi
