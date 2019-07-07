## makefile automates the build and deployment for Emacs Lisp projects

## includes
include $(BUILD_MK_DIR)/elisp.mk

MTARG=		dist

.PHONY:		compile
compile:	elbuild

.PHONY:		deps
deps:		eldeps

.PHONY:		test
test:		eltest

.PHONY:		list
list:		eldistfiles

.PHONY:		lint
lint:		ellint

.PHONY:		doc
doc:		eldoc

.PHONY:		package
package:	elpackage

.PHONY:		deploy
deploy:		eldeploy
