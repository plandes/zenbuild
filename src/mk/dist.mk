## makefile automates the application distribution for lein projects

# edit these if you want
#DIST_PREFIX=	$(HOME)/Desktop
#ZMODEL=	
#ADD_CLEAN+=	$(ASBIN_DIR)

# app assemble (maven plugin
DIST_DIR=	$(if $(DIST_PREFIX),$(DIST_PREFIX)/$(APP_NAME_REF),$(HOME)/Desktop/$(APP_NAME_REF))
DIST_BIN_DIR=	$(DIST_DIR)/bin
ASBIN_DIR=	src/asbin
ASBIN_FILE=	$(ASBIN_DIR)/setupenv

.PHONY: dist
dist:		$(DIST_BIN_DIR)

$(AS_DIR):	$(POM) $(COMP_DEPS)
	lein with-profile +appassem jar
	mvn package appassembler:assemble

$(ASBIN_FILE):
	mkdir -p $(ASBIN_DIR)
	echo 'JAVA_OPTS="-Dzensols.model=$(ZMODEL)"' > $(ASBIN_FILE)

$(DIST_BIN_DIR):	$(ASBIN_FILE) $(AS_DIR)
	mkdir -p $(DIST_DIR)
	cp -r target/appassembler/* $(DIST_DIR)
	[ -d $(ASBIN_DIR) ] && cp -r $(ASBIN_DIR)/* $(DIST_BIN_DIR) || true
	chmod 0755 $(DIST_BIN_DIR)/$(APP_SNAME_REF)

.PHONY:
cleandist:	clean
	@echo "removing $(DIST_DIR)..."
	rm -fr $(DIST_DIR)
