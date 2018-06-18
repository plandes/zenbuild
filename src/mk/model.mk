## makefile automates the application distribution for lein projects

ZMODEL ?=	$$ZMODEL
ASBIN_DIR=	src/asbin
ASBIN_NAME=	setupenv
ASBIN_FILE=	$(ASBIN_DIR)/$(ASBIN_NAME)
COMP_DEPS+=	$(ASBIN_FILE)
ADD_CLEAN_ALL += model
INFO_TARGETS +=	modelinfo

$(ASBIN_FILE):
	mkdir -p $(ASBIN_DIR)
	echo 'JAVA_OPTS="-Dzensols.model=$(ZMODEL)"' > $(ASBIN_FILE)

.PHONY:	modelinfo
modelinfo:
	@echo "zenmodel: $(ZMODEL)"

.PHONY: test
test:	model
	lein test

model:
	@echo creating model
	if [ -z "$$ZMODEL" ] ; then \
		make model-download ; \
	else \
		ln -s $(ZMODEL) || true ; \
	fi

.PHONY:	model-download
model-download:
	mkdir -p model/stanford/pos
	wget -O model/model.zip http://nlp.stanford.edu/software/stanford-postagger-2015-12-09.zip && \
		cd model && \
		unzip model.zip && \
		mv stanford-postagger-2015-12-09/models/english-left3words-distsim.tagger stanford/pos && \
		rm -r model.zip stanford-postagger-2015-12-09
	@echo "see https://github.com/plandes/clj-nlp-parse#setup for details on model configuration"
