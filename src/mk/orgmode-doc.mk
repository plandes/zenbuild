# binaries
OM_EMACS_BIN=		emacs
OM_INSTALL=		install

# build config
OM_DOC_DIR ?=		doc
OM_HTML_DIR ?=		$(OM_DOC_DIR)/html

# export function for output formt
OM_EXPORT_FUNC_HTML ?=	org-html-export-to-html
OM_EXPORT_EVAL ?=	"t"
#OM_EXPORT_FUNC_HTML ?=	org-twbs-export-as-html
#OM_EXPORT_EVAL ?=	"(require 'ox-twbs)"
OM_EXPORT_FUNCS +=	$(OM_EXPORT_FUNC_HTML)

# org files
OM_HTML_FILES ?=	$(patsubst %.org,$(OM_HTML_DIR)/%.html,$(wildcard *.org))

# module config
INFO_TARGETS +=		orgmodeinfo
ADD_CLEAN_ALL +=	$(OM_DOC_DIR)
ADD_OM_DEPS +=


# info
.PHONY:			orgmodeinfo
orgmodeinfo:
			@echo "doc-dir: $(OM_DOC_DIR)"
			@echo "html-dir: $(OM_HTML_DIR)"
			@echo "html-files: $(OM_HTML_FILES)"
			@echo "export-funcs: $(OM_EXPORT_FUNCS)"

# install documentation
.PHONY:			orgmode-install-doc
orgmode-install-doc:	$(OM_HTML_DIR) $(OM_HTML_FILES)	$(ADD_OM_DEPS)

# create the HTML documetnation dir
$(OM_HTML_DIR):
	        	mkdir -v -p $(OM_HTML_DIR)

%.html: %.org
			@for f in $(OM_EXPORT_FUNCS) ; do \
		        	$(OM_EMACS_BIN) $< --batch --eval $(OM_EXPORT_EVAL) -f $$f --kill ; \
			done

$(OM_HTML_DIR)/%.html:	%.html
			$(OM_INSTALL) -v -m 644 -t $(OM_HTML_DIR) $<
