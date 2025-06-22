#@meta {author: "Paul Landes"}
#@meta {desc: "build and deployment for python projects", date: "2025-04-17"}


## Includes
#
include $(BUILD_MK_DIR)/python/build.mk
include $(BUILD_MK_DIR)/python/invoke.mk
include $(BUILD_MK_DIR)/python/git.mk


## Targets
#
# command line help
.PHONY:			help
help:			pyhelp

# dependency tree
.PHONY:			deptree
deptree:		pydeptree

# running the app via Pixi
.PHONY:			invoke
invoke:			pyinvoke

# running the app via the harness
.PHONY:			run
run:			pyharn

# test
.PHONY:			test
test:			pytest

.PHONY:			testprev
testprev:		pytestprev

.PHONY:			testcur
testcur:		pytestcur

.PHONY:			testall
testall:		pytestall

# source control
.PHONY:			mktag
mktag:			pymktag

.PHONY:			rmtag
mtag:			pyrmtag

.PHONY:			bumptag
bumptag:		pybumptag

.PHONY:			check
check:			pycheck

# package
.PHONY:			package
package:		pypackage

.PHONY:			wheel
wheel:			pywheel

# [un,re]install the wheel
.PHONY:			install
install:		pyinstall

.PHONY:			pyuninstall
uninstall:		pyuninstall

.PHONY:			pyreinstall
reinstall:		pyreinstall

# [un,re]install in the global environment
.PHONY:			globalinstall
globalinstall:		pyppinstall

.PHONY:			globaluninstall
globaluninstall:	pyppuninstall

.PHONY:			globalreinstall
globalreinstall:	pyppreinstall

# documentation
.PHONY:			docdeploy
docdeploy:		pydocdeploy

.PHONY:			gitdocdeploy
gitdocdeploy:		pygitdocdeploy

# deploy (needs PROJ_MODULES=python/deploy)
.PHONY:			deploy
deploy:			pydeploy
