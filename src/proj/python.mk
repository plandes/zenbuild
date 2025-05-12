#@meta {author: "Paul Landes"}
#@meta {desc: "build and deployment for python projects", date: "2025-04-17"}


## Includes
#
include $(BUILD_MK_DIR)/python/build.mk


## Targets
#
# test
.PHONY:			test
test:			pytest

# command line help
.PHONY:			help
help:			pyhelp

# dependency tree
.PHONY:			deptree
deptree:		pydeptree

# source control
.PHONY:			mktag
gitmktag:		pymktag

.PHONY:			rmtag
gitrmtag:		pyrmtag

.PHONY:			bumptag
gitbumptag:		pybumptag

.PHONY:			check
check:			pycheck

# package
.PHONY:			package
package:		pypackage

# [un,re]install the wheel
.PHONY:			install
install:		pyinstall

.PHONY:			pyuninstall
uninstall:		pyuninstall

.PHONY:			pyreinstall
reinstall:		pyreinstall

# [un,re]install in the global environment
.PHONY:			installglob
installglobal:		pyinstallglobal

.PHONY:			pyuninstallglobal
uninstallglobal:	pyuninstallglobal

.PHONY:			pyreinstallglobal
reinstallglobal:	pyreinstallglobal

# deploy (needs PROJ_MODULES=python/deploy)
.PHONY:			deploy
deploy:			pydeploy
