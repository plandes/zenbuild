## makefile automates the application distribution for lein projects

# edit these if you want
#DIST_PREFIX=	$(HOME)/Desktop
#ZMODEL=	
#ADD_CLEAN+=	$(ASBIN_DIR)

# app assemble (maven plugin
AS_DIR=		$(MTARG)/appassembler
DIST_DIR=	$(if $(DIST_PREFIX),$(DIST_PREFIX)/$(APP_NAME_REF),target/dist/$(APP_NAME_REF))
DIST_BIN_DNAME=	bin
DIST_BIN_DIR=	$(DIST_DIR)/$(DIST_BIN_DNAME)
DIST_UJAR_REF=	$(if $(DIST_UJAR_NAME),$(DIST_UJAR_NAME),$(ANRRES).jar)
DIST_UJAR_FILE=	$(DIST_DIR)/$(DIST_UJAR_REF)

.PHONY: dist
dist:		$(DIST_BIN_DIR)

.PHONY: distuber
distuber:	checkver uber
	mkdir -p $(DIST_DIR)
	cp $(UBER_JAR) $(DIST_UJAR_FILE)

.PHONY:	distinfo
distinfo:
	@echo "dist dir: $(DIST_DIR)"
	@echo "dist jar: $(DIST_UJAR_FILE)"
	@echo "dist assem: $(DIST_BIN_DIR)"
	@echo "comp deps: $(COMP_DEPS)"

$(AS_DIR):	$(POM) $(COMP_DEPS)
	lein with-profile +appassem jar
	mvn package appassembler:assemble

$(DIST_BIN_DIR):	$(AS_DIR)
	mkdir -p $(DIST_DIR)
	cp -r target/appassembler/* $(DIST_DIR)
	[ ! -z "$(ASBIN_DIR)" ] && [ -d $(ASBIN_DIR) ] && cp -r $(ASBIN_DIR)/* $(DIST_BIN_DIR) || true
	chmod 0755 $(DIST_BIN_DIR)/$(APP_SNAME_REF)

.PHONY:
distclean:	clean
	@echo "removing $(DIST_DIR)..."
	rm -fr $(DIST_DIR)
