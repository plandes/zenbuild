## makefile automates the application distribution for lein projects

ZMODEL ?=	$$ZMODEL
ASBIN_DIR=	src/asbin
ASBIN_NAME=	setupenv
ASBIN_FILE=	$(ASBIN_DIR)/$(ASBIN_NAME)
COMP_DEPS+=	$(ASBIN_FILE)
INFO_TARGETS +=	modelinfo

$(ASBIN_FILE):
	mkdir -p $(ASBIN_DIR)
	echo 'JAVA_OPTS="-Dzensols.model=$(ZMODEL)"' > $(ASBIN_FILE)

.PHONY:	modelinfo
modelinfo:
	@echo "zenmodel: $(ZMODEL)"
