# latex document creation make file
# created: 01/27/2011


## Binary setup
#
# to include in a makefile.in
TEX_SHOWPREV_BIN ?=	rend
TEX_SHOWPREV_ARGS ?=	show $(TEX_PDF_FILE)
TEX_PRESENT_BIN ?=	/Applications/Présentation.app
TEX_PYTHON_BIN ?=	python


## Latex command
#
# should not need to modify these path variables
TEX_nullstr=
TEX_space=		$(TEX_nullstr) $(TEX_nullstr)
ifneq ($(wildcard ./sty/.*),)
TEX_PATH +=		$(abspath ./sty)
endif
TEX_LAT_PATH =		$(MTARG)/lat
TEX_PATH_MTARG =	$(TEX_LAT_PATH) $(TEX_PATH)
TEX_PATHSTR =		$(subst $(TEX_space),:,$(TEX_PATH_MTARG))
# entire tex path (colon) separated syntax
TEX_PATHSEP =		$(subst $(TEX_space),:,$(TEX_PATH)):.
# trailing colon needed
TEX_TPATH =		TEXINPUTS=$(TEX_PATHSTR):
TEX_PDFLAT_ARGS +=
TEX_ENV +=
TEX_BIN ?=		pdflatex
# latex command command
TEX_LATEX_CMD ?=	$(TEX_TPATH) $(TEX_ENV) $(TEX_BIN) -output-directory $(TEX_LAT_PATH) $(TEX_PDFLAT_ARGS)
# make branch
TEX_MAKE_ARGS ?=	--no-print-directory


## Deployment configuration
#
# install/distribution
TEX_INSTALL_DIR ?=	$(HOME)/Desktop
TEX_INSTALL_PDF ?=	$(TEX_INSTALL_DIR)/$(FINAL_NAME).pdf
TEX_INSTALL_ZIP ?=	$(TEX_INSTALL_DIR)/$(FINAL_NAME).zip

# package
TEX_PKG_DIR ?=		$(MTARG)/pkg
TEX_PKG_FINAL_DIR ?= 	$(TEX_PKG_DIR)/$(FINAL_NAME)
TEX_PKG_ADD +=


## Derived object dependency paths
#
TEX_CACHE_DIR ?= 	$(abspath ../cache)
TEX_IMG_DIR ?=		$(abspath ../image)
TEX_IMGC_DIR ?=		$(TEX_CACHE_DIR)/image
TEX_CONF_DIR ?=		$(abspath ../config)

# image file dependencies
TEX_IMG_EPS =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.eps)))
TEX_IMG_PNG =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.png)))
TEX_IMG_JPG =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.jpg)))
TEX_IMG_SVG =		$(addprefix $(TEX_IMGC_DIR)/,$(notdir $(wildcard $(TEX_IMG_DIR)/*.svg)))
TEX_IMAGES =		$(TEX_IMG_EPS) $(TEX_IMG_PNG) $(TEX_IMG_JPG) $(TEX_IMG_SVG)

# target files
TEX_LATEX_FILE =	$(TEX_LAT_PATH)/$(TEX).tex
TEX_PDF_FILE =		$(TEX_LAT_PATH)/$(TEX).pdf
TEX_MTARG_FILE =	$(TEX_LAT_PATH)/mtarg.txt
TEX_PRERUN_FILE =	$(TEX_LAT_PATH)/prerun.txt

# additional tex files
TEX_ADD_LATEX_FILES +=
TEX_ADD_LATEX_DEPS =	$(addprefix $(TEX_LAT_PATH)/,$(TEX_ADD_LATEX_FILES))

# dependencies
TEX_PRE_COMP_DEPS +=	$(TEX_IMAGES)
COMP_DEPS +=		$(TEX_MTARG_FILE) $(TEX_LATEX_FILE) $(TEX_ADD_LATEX_DEPS) \
				$(TEX_PRE_COMP_DEPS) $(TEX_PRERUN_FILE)

## Verbosity and debugging
#
TEX_DEBUG ?=		0
ifeq ($(TEX_DEBUG),0)
# https://tex.stackexchange.com/questions/1191/reducing-the-console-output-of-latex
TEX_PDFLAT_ARGS +=	-interaction batchmode
# no output at all
TEX_QUIET_REDIR ?=	> /dev/null
else
# filter output in "debug mode"
TEX_ENV +=		texfot
endif

# default init commands
TEX_LATEX_INIT_CMD ?=	\newif\ifisfinal
TEX_LATEX_INIT_ADD ?=
TEX_PDFLAT_ARGS +=	'$(TEX_LATEX_INIT_CMD) $(TEX_LATEX_INIT_ADD) \input{$(TEX).tex}'

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
		@mkdir -p $(TEX_LAT_PATH)
		@date >> $(TEX_MTARG_FILE)

# copy over included latex source files
$(TEX_LAT_PATH)/%.tex:		%.tex
		@echo "copy tex file: $< -> $@"
		@mkdir -p $(TEX_LAT_PATH)/$(*D)
		@cp $< $@

# copy over all vector .eps static files
%.eps:		$(TEX_IMG_DIR)/$(@F) $(TEX_MTARG_FILE)
		@echo "copy eps file: $(TEX_IMG_DIR)/$(@F) $@"
		@mkdir -p $(dir $@)
		@cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all vector .pdf static files
%.pdf:		$(TEX_IMG_DIR)/$(@F) $(TEX_MTARG_FILE)
		@echo "copy pdf file: $(TEX_IMG_DIR)/$(@F) $@"
		@cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all raster .png static files
%.png:
		@echo "copy png file: $(TEX_IMG_DIR)/$(@F) $@"
		@cp $(TEX_IMG_DIR)/$(@F) $@

# copy over all raster .jpg static files
%.jpg:
		@echo "copy jpg file: $(TEX_IMG_DIR)/$(@F) $@"
		@cp $(TEX_IMG_DIR)/$(@F) $@

# convert over all svg to pdf files
%.svg:
		@if [ ! -f $*.eps ] ; then \
			echo "converting $(TEX_IMG_DIR)/$(@F) -> $*.eps" ; \
			inkscape $(TEX_IMG_DIR)/$(@F) --export-filename=$*.eps ; \
		fi

.PHONY:		texversion
texversion:
		( cd /Library/TeX/Root && pwd -P )

# recompile even when editing .sty files (make proper dependencies?)
.PHONY:		texforce
texforce:	$(COMP_DEPS)
		@echo "forcing make"
		@$(MAKE) $(TEX_MAKE_ARGS) $(COMP_DEPS)
		@( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) )

# run latex before resolving module targets (see tex-bib*.mk, tex-index.mk)
$(TEX_PRERUN_FILE):
		@echo "init run: $(TEX_INIT_RUN)"
		@if [ ! -z "$(TEX_INIT_RUN)" ] ; then \
			if [ -d $(TEX_IMGC_DIR) ] ; then \
				echo "copying images $(TEX_IMGC_DIR) -> $(TEX_LAT_PATH)" ; \
				cp $(TEX_IMGC_DIR)/* $(TEX_LAT_PATH) ; \
			fi ; \
			echo "starting latex pre-start run : $(TEX_LAT_PATH)" ; \
			if [ $(TEX_DEBUG) -eq 1 ] ; then \
				echo "( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) )" ; \
			fi ; \
			( cd $(TEX_LAT_PATH) ; $(TEX_LATEX_CMD) ) ; \
			if [ $$? != 0 ] ; then \
				echo "failed last compile (use TEX_DEBUG=1): $$?" ; \
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
		@echo "debugging tex build..."
		@$(MAKE) $(TEX_MAKE_ARGS) TEX_DEBUG=1 texforce

# compile and display the file using a simple open (MacOS or alias out)
.PHONY:		texopen
texopen:	texcompile
		@echo "opening $(TEX_PDF_FILE)..."
		@open $(TEX_PDF_FILE)

# a one pass compile and show (will flub refs and bibliography)
.PHONY:		texreopen
texreopen:	texforce
		@echo "bringing preview to foreground..."
		@osascript -e 'tell application "Preview" to activate'

.PHONY:		texrend
texrend:
		$(TEX_SHOWPREV_BIN) $(TEX_SHOWPREV_ARGS)

# show and reposition the Preview.app window (under MacOS)
.PHONY:		texshow
texshow:	texforce texrend

# run in "debug mode" and then show
.PHONY:		texdebugshow
texdebugshow:	texdebug texrend

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

# create the final version, then display it like texshow
.PHONY:		texfinalshow
texfinalshow:	texfinal texrend

# force compile the presentation version
.PHONY:			texpresentforce
texpresentforce:
			@$(MAKE) $(TEX_MAKE_ARGS) \
				TEX_LATEX_INIT_CMD="\newif\ifisfinal\isfinaltrue \def\ispresentation{1}" \
				texforce

# kill the presentation app if running, then restart with new file version
.PHONY:			texpresentopen
texpresentopen:
			@for i in $$( ps -eaf | grep presentation.py | grep -v grep | awk '{print $$2}' ) ; do \
				kill $$i ; \
			done
			open -a $(TEX_PRESENT_BIN) $(TEX_PDF_FILE)

# compile and view the presentation version of the file in the presentation app
.PHONY:			texpresentshow
texpresentshow:		texpresentforce texpresentopen

# create the presentation form of the slides
.PHONY:		texpresentpdf
texpresentpdf:
		@echo "creating prsentation slides; final runs: $(TEX_FINAL_RUNS)"
		@for i in `seq $(TEX_FINAL_RUNS)` ; do \
			echo "run number $$i" ; \
			make texpresentforce ; \
			if [ $$? != 0 ] ; then \
				exit 1 ; \
			fi ; \
		done

# present a slide deck
.PHONY:		texpresent
texpresent:	texpackage
		@echo "Imporant: uncheck Mirror Mode: Sys Prefs > Display > Arragenemnt"
		open -a $(TEX_PRESENT_BIN) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME)-presenetation.pdf

# create a zip file with the only the PDF as its contents
.PHONY:		texpackage
texpackage:	$(TEX_PKG_FINAL_DIR) $(TEX_PKG_ADD)

# package directory target generates both slides versions or default paper/report
$(TEX_PKG_FINAL_DIR):
		@echo "packaging into $(TEX_PKG_FINAL_DIR)..."
		@mkdir -p $(TEX_PKG_FINAL_DIR)
		@$(MAKE) $(TEX_MAKE_ARGS) texfinal
		@if [ -z "$(TEX_SLIDES)" ] ; then \
			echo "copying non-slides file to package dir" ; \
			cp $(TEX_PDF_FILE) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME).pdf ; \
		else \
			echo "copying slides files to package dir" ; \
			cp $(TEX_PDF_FILE) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME)-slides.pdf ; \
			rm -rf $(TEX_LAT_PATH) ; \
			make texpresentpdf ; \
			cp $(TEX_PDF_FILE) $(TEX_PKG_FINAL_DIR)/$(FINAL_NAME)-presenetation.pdf ; \
		fi

# create final version, compress if mulitple files, then copy to install
# location
.PHONY:		texinstall
texinstall:	texpackage
		@if [ ! -z "$(TEX_PKG_ADD)" ] ; then \
			cp $(TEX_PKG_ADD) $(TEX_PKG_DIR)/$(FINAL_NAME) ; \
		fi
		@if [ `ls $(TEX_PKG_DIR)/$(FINAL_NAME) | wc -l` -gt 1 ] ; then \
			echo "installing zip of all resources..." ; \
			( cd $(TEX_PKG_DIR) ; zip -r $(FINAL_NAME).zip $(FINAL_NAME) ) ; \
			cp $(TEX_PKG_DIR)/$(FINAL_NAME).zip $(TEX_INSTALL_ZIP) ; \
		else \
			echo "installing just PDF to $(TEX_INSTALL_PDF)" ; \
			cp $(TEX_PKG_DIR)/$(FINAL_NAME)/$(FINAL_NAME).pdf $(TEX_INSTALL_PDF) ; \
		fi

# compile a final version and copy it to the install directory with a unique
# file name
.PHONY:			texinstalltracked
texinstalltracked:	compile
			$(eval DFMT=$(shell date "+$(USER)-$(FINAL_NAME)-%b%d-%H%M" | tr "A-Z" "a-z"))
			@echo "copy tex source and PDF to $(TEX_INSTALL_DIR)..."
			@cp $(TEX).tex $(TEX_INSTALL_DIR)/$(DFMT).tex
			@cp $(TEX_PDF_FILE) $(TEX_INSTALL_DIR)/$(DFMT).pdf
