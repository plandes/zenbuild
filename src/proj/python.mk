## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/python.mk

.PHONY:		run
run:		pycli

.PHONY:		help
help:		pyhelp

.PHONY:		test
test:		pytest

.PHONY:		package
package:	pypackage

.PHONY:		deps
deps:		pydeps

.PHONY:		deptree
deptree:	pydeptree

.PHONY:		install
install:	pyinstall

.PHONY:		uninstall
uninstall:	pyuninstall

.PHONY:		reinstall
reinstall:	uninstall install

.PHONY:		installnotest
installnotest:	uninstall pyinstallnotest

.PHONY:		reinstallnotest
reinstallnotest:	uninstall pyinstallnotest

.PHONY:		doc
doc:		pydochtml

.PHONY:		deploy
deploy:		pydist
