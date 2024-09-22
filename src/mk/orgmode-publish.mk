#@meta {desc: 'Emacs Org using the publish functionality', date: '2021-08-08'}


## Build
#
# override the execution target to publish vs. export from orgmode-doc.mk
OM_BUILD_TARG =		orgmode-publish-html


## Project
#
# export function for output formt: use Bootstrap compatible HTML Back-End for
# Org instead of default emacs
#OM_PB_FUNC_HTML ?=	org-html-publish-to-html
OM_PB_FUNC_HTML ?=	org-twbs-publish-to-html

# set this to "t" in the makefile to enable zotero to zotsite links
# (https://github.com/plandes/zotsite) and environment variable CNT_SITE_SERV
# to be set to the URL of your deployed Zotero site.
OM_PB_BET_BIB_USE ?=	nil

# declare additional directories to copy to the site export directory
OM_PB_SITE_OBJS +=	

# emacs lisp that invokes the org-mode publish
OM_PB_EXPORT_EVAL =	$(subst FILE,$(OM_MD_ORG_NAME),\
			$(subst OM_PB_FUNC_HTML,$(OM_PB_FUNC_HTML),\
			$(subst OM_PB_SITE_OBJS,$(OM_PB_SITE_OBJS),\
			$(subst OM_PB_BET_BIB_USE,$(OM_PB_BET_BIB_USE),\
			$(subst OM_HTML_DIR,$(OM_HTML_DIR),"\
(progn\
  (load \"~/.emacs\")\
  (require 'zotsite)\
  (setq zotsite-url (getenv \"CNT_SITE_SERV\"))\
  (with-temp-buffer (org-mode)\
  (find-file \"FILE\")\
  (zotsite-publish \"OM_HTML_DIR\" 'OM_PB_FUNC_HTML OM_PB_BET_BIB_USE \"OM_PB_SITE_OBJS\")))"\
			)))))


## Targets
#
# 
# only invoke the publish process to generate the site files if necessary
.PHONY:			orgmode-publish-html
orgmode-publish-html:
			@if [ ! -d $(OM_HTML_DIR) ] ; then \
				make orgmode-publish-invoke ; \
			else \
				echo "nothing to do (try cleaning): $(OM_HTML_DIR) exists" ; \
			fi

# invoke the publish process to generate the site files
.PHONY:			orgmode-publish-invoke
orgmode-publish-invoke:
			@echo "publishing..."
			@echo $(OM_PB_EXPORT_EVAL)
	        	$(EMACS_BIN) $(OM_EMACS_SWITCHES) --batch \
			 	--eval $(OM_PB_EXPORT_EVAL) --kill
