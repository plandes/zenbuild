## make include file for Emacs Org using the publish functionality
## PL 8/08/2021


# override the execution target to publish vs. export from orgmode-doc.mk
OM_BUILD_TARG =		orgmode-publish-html


# project

# export function for output formt: use Bootstrap compatible HTML Back-End for
# Org instead of default emacs
#OM_PB_FUNC_HTML ?=	org-html-publish-to-html
OM_PB_FUNC_HTML ?=	org-twbs-publish-to-html
# the script to create BetterBibtex item key to better bibtex ID mapping
OM_PB_BET_BIB_PROG ?=	$(BUILD_BIN_DIR)/betterbibdb.py
# set this to 1 in the makefile to enable zotero to zotsite links
# (https://github.com/plandes/zotsite) and environment variable CNT_SITE_SERV
# to be set to the URL of your deployed Zotero site.
OM_PB_BET_BIB_USE ?=	0
ifeq ($(OM_PB_BET_BIB_USE),1)
OM_PB_BET_BIB_PROG_USE = \"$(OM_PB_BET_BIB_PROG)\"
else
OM_PB_BET_BIB_PROG_USE = nil
endif
# declare additional directories to copy to the site export directory
OM_PB_SITE_OBJS +=	
# emacs lisp that invokes the org-mode publish
OM_PB_EXPORT_EVAL =	$(subst PUB_LIB,$(BUILD_SRC_DIR)/emacs/zb-org-mode.el,\
			$(subst FILE,$(OM_MD_ORG_NAME),\
			$(subst OM_PB_FUNC_HTML,$(OM_PB_FUNC_HTML),\
			$(subst OM_PB_SITE_OBJS,$(OM_PB_SITE_OBJS),\
			$(subst OM_PB_BET_BIB_PROG,$(OM_PB_BET_BIB_PROG_USE),\
			$(subst OM_HTML_DIR,$(OM_HTML_DIR),"\
(progn\
  (load \"~/.emacs\")\
  (load \"PUB_LIB\")\
  (with-temp-buffer (org-mode)\
  (find-file \"FILE\")\
  (zb-org-mode-publish \"OM_HTML_DIR\" 'OM_PB_FUNC_HTML OM_PB_BET_BIB_PROG \"OM_PB_SITE_OBJS\")))"\
			))))))


# targets

.PHONY:			orgmode-publish-html
orgmode-publish-html:
			@if [ ! -d $(OM_HTML_DIR) ] ; then \
				make orgmode-publish-invoke ; \
			else \
				echo "nothing to do (try cleaning): $(OM_HTML_DIR) exists" ; \
			fi

.PHONY:			orgmode-publish-invoke
orgmode-publish-invoke:
			@echo "publishing..."
			@echo $(OM_PB_EXPORT_EVAL)
	        	$(EMACS_BIN) $(OM_EMACS_SWITCHES) --batch \
			 	--eval $(OM_PB_EXPORT_EVAL) --kill
