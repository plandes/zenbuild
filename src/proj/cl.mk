# ANSI common lisp
# Created: 5/22/2023

# entry application
CL_PROTO_APP ?= 	./main.ros

# run arguments
CL_RUN_ARGS ?=		run

# info
INFO_TARGETS +=		clinfo

# silence warnings on git.mk import
GIT_BUILD_INFO_BIN =	echo


.PHONY:			test
test:
			$(CL_PROTO_APP) test

.PHONY:			run
run:
			$(CL_PROTO_APP) $(CL_RUN_ARGS)

.PHONY:			clinfo
clinfo:
			@echo "proto-app: $(PROTO_APP)"
