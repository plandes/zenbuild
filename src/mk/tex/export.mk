# latex export: create an export of the system so someone else can compile with
# make, or for arXiv submissions
#
# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-export


## Environment
#
# executables
TEX_EXPORT_IMG_CLEAN =	$(BUILD_BIN_DIR)/cleanlatex.py
TEX_EXPORT_LATIDX =	latidx

# tex path
TEX_EXPORT_SPACE :=	$(subst ,, )
# latidx path
TEX_EXPORT_LATIDX_PATH=	$(TEX_PATHSEP):$(TEX_LAT_PATH)

# paths
TEX_EXPORT_DIR ?=	$(MTARG)/export/$(FINAL_NAME)
TEX_EXPORT_ZIP_DIR ?=	$(notdir $(TEX_EXPORT_DIR))
TEX_EXPORT_ZIP ?=	$(FINAL_NAME).zip
TEX_EXPORT_INST_ZIP ?=	$(TEX_INSTALL_DIR)/$(TEX_EXPORT_ZIP)
# clean unused image files not needed in the latex file
#TEX_EXPORT_DEPS +=	texexportimgclean

# additional files to include
TEX_EXPORT_ADDS +=

# include PDF with all compiled derived objects in zip
TEX_EXPORT_ADD_PDF ?=

# build
INFO_TARGETS +=		texexportinfo
ADD_CLEAN_ALL +=	$(TEX_EXPORT_INST_ZIP)


## Targets
#
.PHONY:		texexportinfo
texexportinfo:
		@echo "tex-export-latidx-path: $(TEX_EXPORT_LATIDX_PATH)"

# re-export running only the necessary steps to create the export directory
# handy for debugging
.PHONY:		texexportredo
texexportredo:
		@echo "removing $(TEX_EXPORT_DIR), $(TEX_EXPORT_DIR).zip..."
		@rm -fr $(TEX_EXPORT_DIR)
		@rm -f $(TEX_EXPORT_DIR).zip
		@make $(TEX_MAKE_ARGS) texexport

# prepare for export by copy files and creating configuration
.PHONY:		texexportprep
texexportprep:	texinstall
		@echo "prepare export in $(TEX_EXPORT_DIR)..."
		@mkdir -p $(TEX_EXPORT_DIR)
		@cp $(wildcard $(BIB_FILE) $(BBL_FILE)) $(TEX_EXPORT_DIR)
		@cp $(wildcard $(TEX_LAT_PATH)/*.eps $(TEX_LAT_PATH)/*.png \
			$(TEX_LAT_PATH)/*.jpg $(TEX_LAT_PATH)/*.gif) \
			$(TEX_EXPORT_DIR)
		@if [ ! -z "$(TEX_EXPORT_ADDS)" ] ; then \
			cp -r $(TEX_EXPORT_ADDS) $(TEX_EXPORT_DIR) ; \
		fi
		@$(TEX_EXPORT_LATIDX) deps $(TEX_EXPORT_LATIDX_PATH) \
			--source $(TEX_LATEX_FILE) -f list | \
			grep -v $(notdir $(TEX_LATEX_FILE)) | \
			xargs -i{} cp {} $(TEX_EXPORT_DIR)
		@cat $(BUILD_SRC_DIR)/template/tex/export-makefile | \
			sed 's/{{TEX_FILE_NAME}}/$(FINAL_NAME)/g' | \
			sed 's/{{TEX_LATEX_CMD}}/$(TEX_BIN)/g' | \
			sed 's/{{TEX_FINAL_RUNS}}/$(TEX_FINAL_RUNS)/g' | \
			sed 's/{{SRC_FILE_NAME}}/$(TEX)/g' > \
			$(TEX_EXPORT_DIR)/makefile
		@echo "\\\newif\ifisfinal\isfinaltrue" > \
			$(TEX_EXPORT_DIR)/$(FINAL_NAME).tex
		@cat $(TEX).tex >> $(TEX_EXPORT_DIR)/$(FINAL_NAME).tex
		@if [ ! -z "$(BIBER)" ] ; then \
			touch $(TEX_EXPORT_DIR)/zenbiber ; \
		fi

# print (use)package dependency tree
.PHONY:		texexportdeps
texexportdeps:	texcompile
		@echo "tex path: $(TEX_EXPORT_LATIDX_PATH)"
		@$(TEX_EXPORT_LATIDX) deps $(TEX_EXPORT_LATIDX_PATH) \
			--source $(TEX_LATEX_FILE)

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

# create a zip file to be uploaded to arXiv
.PHONY:		texexportarxiv
texexportarxiv:	clean texexportprep texexportbibrename texexport
