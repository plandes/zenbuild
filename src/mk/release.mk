REL_DIR=	rel
REL_PREP_DIR=	$(REL_DIR)/prep
REL_BIN_DIR=	$(REL_DIR)/dist
REL_PREFIX=	$(ANRRES)
REL_ZIP=	$(REL_BIN_DIR)/$(REL_PREFIX).zip
REL_BZ2=	$(REL_BIN_DIR)/$(REL_PREFIX).tar.bz2
REL_UBER=	$(REL_BIN_DIR)/$(ANRRES).jar
REL_DIST ?=	$(REL_UBER) $(REL_ZIP) $(REL_BZ2)

ADD_CLEAN +=	$(REL_DIR)

.PHONY:	reldist
reldist:	release relupload

.PHONY:	relupload
relupload:
		ghrelease -r $(GITUSER)/$(PROJ_REF) -p $(REL_BIN_DIR)/*

.PHONY:	release
release:	$(REL_BIN_DIR)

$(REL_BIN_DIR):	$(REL_DIST)
		for i in $(REL_BIN_DIR)/* ; do \
			gpg --armor --detach-sign $$i ; \
		done

.PHONY: relapp
relapp:		$(REL_ZIP) $(REL_BZ2)

$(REL_PREP_DIR):	$(AS_DIR)
	mkdir -p $(REL_PREP_DIR)
	mkdir -p $(REL_BIN_DIR)
	cp -r $(AS_DIR) $(REL_PREP_DIR)/$(REL_PREFIX)

.PHONY: relzip
relzip:		$(REL_ZIP)
$(REL_ZIP):	$(REL_PREP_DIR)
	( cd $(REL_PREP_DIR) ; zip -r ../../$(REL_ZIP) $(REL_PREFIX) )

.PHONY: relbz2
relbz2:		$(REL_BZ2)
$(REL_BZ2):	$(REL_PREP_DIR)
	( cd $(REL_PREP_DIR) ; tar cf - $(REL_PREFIX) | bzip2 > ../../$(REL_BZ2) )

.PHONY: reluber
reluber:	$(REL_UBER)
# this deletes target/ whether we like it or not (from lein)
$(REL_UBER):	$(UBER_JAR)
	mkdir -p $(REL_BIN_DIR)
	cp $(UBER_JAR) $(REL_UBER)

.PHONY: relclean
relclean:
	rm -fr $(REL_PREP_DIR) $(REL_BIN_DIR)
