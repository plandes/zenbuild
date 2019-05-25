## make include file for Emacs Org projects
## PL 12/08/2018

# binaries
OM_EMACS_BIN ?=		emacs
OM_ORG_SWITCHES +=	--no-window-system
OM_INSTALL ?=		install

# build config
OM_DOC_DIR ?=		$(MTARG)/doc
OM_HTML_DIR ?=		$(OM_DOC_DIR)/html
OM_SHOW_FILES ?=	$(OM_HTML_DIR).html

# export function for output formt
OM_EXPORT_FUNC_HTML ?=	org-html-export-to-html
# use Bootstrap compatible HTML Back-End for Org instead of default emacs
OM_EXPORT_FUNC_HTML =	org-twbs-export-to-html
# load default setup and force Orgmode initialization with `org-mode' call
OM_EXPORT_EVAL =	"(progn (load \"~/.emacs\") (with-temp-buffer (org-mode)))"
OM_EXPORT_FUNCS +=	$(OM_EXPORT_FUNC_HTML)

# org files
OM_ORG_FILES +=		$(wildcard *.org)
OM_HTML_FILES ?=	$(patsubst %.org,$(OM_HTML_DIR)/%.html,$(OM_ORG_FILES))

# module config
INFO_TARGETS +=		orgmodeinfo
ADD_OM_DEPS +=


# info
.PHONY:			orgmodeinfo
orgmodeinfo:
			@echo "doc-dir: $(OM_DOC_DIR)"
			@echo "html-dir: $(OM_HTML_DIR)"
			@echo "html-files: $(OM_HTML_FILES)"
			@echo "export-funcs: $(OM_EXPORT_FUNCS)"

# install documentation
.PHONY:			orgmode-html
orgmode-html:		$(OM_HTML_DIR) $(OM_HTML_FILES)	$(ADD_OM_DEPS)

# create the HTML documetnation dir
$(OM_HTML_DIR):
	        	mkdir -v -p $(OM_HTML_DIR)

# use emacs org html export to genereate the files
%.html: %.org
			@for f in $(OM_EXPORT_FUNCS) ; do \
		        	echo $(OM_EMACS_BIN) $< $(OM_EMACS_SWITCHES) --batch --eval $(OM_EXPORT_EVAL) -f $$f --kill ; \
		        	$(OM_EMACS_BIN) $< $(OM_EMACS_SWITCHES) --batch --eval $(OM_EXPORT_EVAL) -f $$f --kill ; \
			done

$(OM_HTML_DIR)/%.html:	%.html
			$(OM_INSTALL) -v -m 644 -t $(OM_HTML_DIR) $<

# generate the HTML and browse to the file
.PHONY:			orgmode-show
orgmode-show:		orgmode-html
			@for i in $(OM_SHOW_FILES) ; do \
				open $$i ; \
			done
