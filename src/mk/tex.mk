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
PRERUN_FILE=	$(MTARG)/prerun.txt

# dependencies
COMP_DEPS +=	$(MTARG_FILE) $(TEX_FILE) $(VECEPS) $(IMAGES) $(GRAFFLES) $(PRERUN_FILE)

# compiles faster in Emacs avoiding fontification of verbose output
QUIET ?=	> /dev/null

# default position of Preview.app
PREV_POS ?=	{1500, 0}
PREV_SIZE ?=	{1400, 1600}

# invokes a pre run
TEX_INIT_RUN =
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

# shortgap for dependency marker (with the exception of the .tex file) for now
$(MTARG_FILE):
		mkdir -p $(MTARG)
		date >> $(MTARG_FILE)

# compile all OmniGraffle files
%.graffle:	$(MTARG_FILE)
		cp -r $(GRAFFLE_DIR)/$(@F) $@
		osascript $(GRAF_BIN) $@ $(MTARG)

# copy over all vector .eps static files
%.eps:		$(VEC_DIR)/$(@F) $(MTARG_FILE)
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
		( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) )

# force recompile and snow
.PHONY:		forceshow
texforceshow:	force texshowpdf

# run latex before resolving module targets (see tex-bib*.mk, tex-index.mk)
$(PRERUN_FILE):
		@echo "init run: $(TEX_INIT_RUN)"
		@if [ ! -z "$(TEX_INIT_RUN)" ] ; then \
			echo "starting latex pre-start run..." ; \
			( cd $(MTARG) ; $(LATEX_BIN) $(TEX).tex $(QUIET) ) ; \
			date >> $(PRERUN_FILE) ; \
		fi

# top level dependency (add sty files as dependencies later?)
$(TEX_FILE):	$(TEX).tex
		cp $(TEX).tex $(MTARG)

# build the PDF
.PHONY:		texpdf
texpdf:		$(PDF_FILE)

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

# final version: compile twice for refs and bibliography then copy to desktop
.PHONY:		texfinal
texfinal:
		make SECOND_RUN=1 texpdf

# create a zip file with the only the PDF as its contents
.PHONY:		texdist
texdist:	texfinal
		@if [ ! -z "$(FINAL_PDF_NAME)" ] ; then \
			echo "copy $(PDF_FILE) -> $(FINAL_PDF_NAME)..." ; \
			cp $(PDF_FILE) "$(FINAL_PDF_NAME)" ; \
		fi

# compile and display the file using a simple open (MacOS or alias out)
.PHONY:		texshowpdf
texshowpdf:	texpdf
		open $(PDF_FILE)

# compile the final version and show in Preview
.PHONY:		texfinalshow
texfinalshow:	texfinal texshowpdf

# a one pass compile and show (will flub refs and bibliography)
.PHONY:		texshowquick
texshowquick:
		make PROJ_MODULES= SECOND_RUN= texshowpdf

# show and reposition the Preview.app window (under MacOS)
.PHONY:		texreposition
texreposition:	texpdf
		open $(PDF_FILE)
		osascript $(SHOWPREV_BIN) $(PDF_FILE) $(PREV_LOC)

# create a no dependency (from zenbuild) directory with files to recreate PDF
.PHONY:		texexport
texexport:	pdf
		mkdir -p $(EXPORT_DIR)
		cp $(wildcard $(TEX).tex $(BIB_FILE) $(BBL_FILE)) $(EXPORT_DIR)
		cp $(wildcard $(MTARG)/*.eps $(MTARG)/*.png $(MTARG)/*.jpg $(MTARG)/*.gif) $(EXPORT_DIR)
		cp $(wildcard $(addsuffix /*,$(TIPATH))) $(EXPORT_DIR)
		cp $(BUILD_SRC_DIR)/template/tex-export-makefile $(EXPORT_DIR)/makefile

# create no dependency and show file
.PHONY:		texshowexport
texshowexport:	texexport
		make -C $(EXPORT_DIR)
		open $(EXPORT_DIR)/$(TEX).pdf

# present a slide deck
.PHONY:		texpresent
texpresent:	texfinal
		$(PYTHON_BIN) $(PRESENT_BIN) $(PDF_FILE)
