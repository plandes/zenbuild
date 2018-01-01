## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/python.mk

.PHONY:	run
run:		pyrun

.PHONY:	test
test:		pytest

.PHONY:	package
package:	pypackage

.PHONY:	deps
deps:		pydeps

.PHONY: install
install:	pyinstall

.PHONY:	uninstall
uninstall:	pyuninstall

.PHONY:	reinstall
reinstall:	uninstall install
