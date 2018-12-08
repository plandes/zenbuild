## makefile automates org mode files/documents

## includes
include $(BUILD_MK_DIR)/orgmode-doc.mk


.PHONY:			doc
doc:			orgmode-install-doc

.PHONY:			show
show:			orgmode-show
