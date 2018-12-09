## makefile automates org mode files/documents

CNT_DEP_TARGS +=	orgmode-html
CNT_SRC_DIR ?=		$(OM_HTML_DIR)/

## includes
include $(BUILD_MK_DIR)/orgmode-doc.mk
include $(BUILD_MK_DIR)/content.mk


.PHONY:			doc
doc:			orgmode-install-doc

.PHONY:			show
show:			orgmode-show

.PHONY:			deploy
deploy:			cntdeploy

.PHONY:			run
run:			cntrun
