#@meta {author: "Paul Landes"}
#@meta {desc: "ANSI common lisp", date: "2023-05-22"}


## Module
#
# entry application
CL_PROTO_APP ?= 	./main.ros

# run arguments
CL_RUN_ARGS ?=		run

# info
INFO_TARGETS +=		clinfo

# clean
CLEAN_DEPS +=		clclean

# silence warnings on git.mk import
GIT_BUILD_INFO_BIN =	echo


## Targets
#
.PHONY:			test
test:
			$(CL_PROTO_APP) test

.PHONY:			run
run:
			$(CL_PROTO_APP) $(CL_RUN_ARGS)

.PHONY:			clinfo
clinfo:
			@echo "proto-app: $(PROTO_APP)"


.PHONY:			clclean
clclean:
			find . -type f -name \*.fasl -exec rm {} \;
