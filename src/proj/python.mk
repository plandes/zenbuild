## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/python.mk

.PHONY:	run
run:		pytest

.PHONY:	test
test:		pytest

.PHONY:	package
package:	pypackage
