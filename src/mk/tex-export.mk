# latex export: create an export of the system so someone else can compile with
# make, or for arXiv submissions
# created: 9/07/2021

## environment
#
# bin
TEX_EXPORT_IMG_CLEAN=	$(BUILD_BIN_DIR)/cleanlatex.py

# export
TEX_EXPORT_DIR ?=	$(MTARG)/export
TEX_EXPORT_ZIP_DIR ?=	$(notdir $(TEX_EXPORT_DIR))
TEX_EXPORT_ZIP ?=	$(FINAL_NAME).zip
TEX_EXPORT_INST_ZIP ?=	$(TEX_INSTALL_DIR)/$(TEX_EXPORT_ZIP)
# clean unused image files not needed in the latex file
#TEX_EXPORT_DEPS +=	texexportimgclean

# include PDF with all compiled derived objects in zip
TEX_EXPORT_ADD_PDF ?=

# build
ADD_CLEAN_ALL +=	$(TEX_EXPORT_INST_ZIP)


## targets
#
# re-export running only the necessary steps to create the export directory
# handy for debugging
.PHONY:		texexportredo
texexportredo:
		rm -fr $(TEX_EXPORT_DIR)
		make texexport

# prepare for export by copy files and creating configuration
.PHONY:		texexportprep
texexportprep:	texinstall
		mkdir -p $(TEX_EXPORT_DIR)
		cp $(wildcard $(BIB_FILE) $(BBL_FILE)) $(TEX_EXPORT_DIR)
		cp $(wildcard $(TEX_LAT_PATH)/*.eps $(TEX_LAT_PATH)/*.png \
			$(TEX_LAT_PATH)/*.jpg $(TEX_LAT_PATH)/*.gif \
			$(TEX_LAT_PATH)/*.sty) $(TEX_EXPORT_DIR)
		cp $(wildcard $(addsuffix /*,$(TEX_PATH))) $(TEX_EXPORT_DIR)
		cat $(BUILD_SRC_DIR)/template/tex/export-makefile | \
			sed 's/{{TEX_FILE_NAME}}/$(FINAL_NAME)/g' | \
			sed 's/{{TEX_FINAL_RUNS}}/$(TEX_FINAL_RUNS)/g' | \
			sed 's/{{SRC_FILE_NAME}}/$(TEX)/g' > \
			$(TEX_EXPORT_DIR)/makefile
		echo "\\\newif\ifisfinal\isfinaltrue" > \
			$(TEX_EXPORT_DIR)/$(FINAL_NAME).tex
		cat $(TEX).tex >> $(TEX_EXPORT_DIR)/$(FINAL_NAME).tex
		if [ ! -z "$(BIBER)" ] ; then \
			touch $(TEX_EXPORT_DIR)/zenbiber ; \
		fi

# remove superfluous image files
.PHONY:		texexportimgclean
texexportimgclean:
		@echo "cleaning superfluous image files"
		$(TEX_EXPORT_IMG_CLEAN) $(TEX_EXPORT_DIR)
		@if [ ! -z "$(TEX_EXPORT_ADD_PDF)" ] ; then \
			echo "compiling PDF to include in distribution" ; \
			make -C $(TEX_EXPORT_DIR) ; \
		fi

# renaming any bib files to final name (useful for arXiv submissions)
.PHONY:		texexportbibrename
texexportbibrename:
		@echo "renaming any bib files to final name"
		@( cd $(TEX_EXPORT_DIR) ; \
		  for i in *.bib ; do \
			echo "renmaing $$i $(FINAL_NAME).bib" ; \
			mv $$i $(FINAL_NAME).bib ; \
		  done ; \
		  recrepl -r $(FINAL_NAME).bib $$i ; \
		  recrepl -r $(FINAL_NAME).bbl $$i ; \
		  for i in *.bbl ; do \
			echo "renmaing $$i $(FINAL_NAME).bbl" ; \
			mv $$i $(FINAL_NAME).bbl ; \
		  done )

# create a no dependency (from zenbuild) directory with files to recreate PDF
.PHONY:		texexport
texexport:	texexportprep $(TEX_EXPORT_DEPS)
		( cd $(TEX_EXPORT_DIR)/.. ; \
			zip -r $(TEX_EXPORT_ZIP) $(TEX_EXPORT_ZIP_DIR) ; \
			cp $(TEX_EXPORT_ZIP) $(TEX_EXPORT_INST_ZIP) )
		@echo "exported stand-alone build to $(TEX_EXPORT_INST_ZIP)"
