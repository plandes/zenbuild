## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/python.mk

# run the program with default parameters using the Python CLI make system
.PHONY:			run
run:			pycli

# print the program command line help using the Python CLI make system
.PHONY:			help
help:			pyhelp

# run the unit tests
.PHONY:			test
test:			pytest

# create the wheel distribution binary
.PHONY:			package
package:		pypackage

# pip install dependencies
.PHONY:			deps
deps:			pydeps

# run pip check
.PHONY:			deps
depcheck:		pydepcheck

# print the python dependency tree
.PHONY:			deptree
deptree:		pydeptree

# build and install the package locally
.PHONY:			install
install:		pyinstall

# uninstall the package locally
.PHONY:			uninstall
uninstall:		pyuninstall

# remove the locally installed library (if installed), build and install
.PHONY:			reinstall
reinstall:		uninstall install

# same as `install` but do not run the tests
.PHONY:			installnotest
installnotest:		uninstall pyinstallnotest

# same as `reinstall` but do not run the tests
.PHONY:			reinstallnotest
reinstallnotest:	uninstall pyinstallnotest

# generate the API HTML documentation
.PHONY:			doc
doc:			pydochtml

# like `doc` but deploy it to local site after generation
.PHONY:			docdeploy
docdeploy:		pydocdeploy

# deploy the application to PyPi
.PHONY:			deploy
deploy:			pydist
