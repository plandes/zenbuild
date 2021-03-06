## make include file to create README.md files from notes

OM_MD_FILE_NAME ?=	README.md

OM_MD_ORG_NAME	?=	$(CNT_SITE_NAME).org

OM_MD_EXPORT_EVAL =	$(subst README,$(OM_MD_FILE_NAME),$(subst FILE,$(OM_MD_ORG_NAME),"\
(progn (load \"~/.emacs\")\
  (with-temp-buffer (org-mode)\
  (find-file \"FILE\")\
  (org-export-to-file 'gfm \"README\")))"))

CNT_DEP_TARGS +=	$(OM_MD_FILE_NAME)

ADD_CLEAN_ALL +=	$(OM_MD_FILE_NAME)

.PHONY:			orgmode-markdown
orgmode-markdown:	$(OM_MD_FILE_NAME)

$(OM_MD_FILE_NAME):
	        	$(EMACS_BIN) $< $(OM_EMACS_SWITCHES) --batch \
			 	--eval $(OM_MD_EXPORT_EVAL) --kill
