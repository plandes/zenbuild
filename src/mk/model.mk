## makefile automates the application distribution for lein projects

ASBIN_DIR=	src/asbin
ASBIN_NAME=	setupenv
ASBIN_FILE=	$(ASBIN_DIR)/$(ASBIN_NAME)
COMP_DEPS+=	$(ASBIN_FILE)
# $(AS_DIR)

$(ASBIN_FILE):
	mkdir -p $(ASBIN_DIR)
	echo 'JAVA_OPTS="-Dzensols.model=$(ZMODEL)"' > $(ASBIN_FILE)
