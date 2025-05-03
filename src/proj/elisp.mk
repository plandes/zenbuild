#@meta {author: "Paul Landes"}
#@meta {desc: "build and deploy Emacs Lisp projects", date: "2025-04-27"}


## Includes
##

include $(BUILD_MK_DIR)/elisp.mk


## Targets
#
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

.PHONY:		docs
docs:		eldoc

.PHONY:		package
package:	elpackage

.PHONY:		deploy
deploy:		eldeploy
