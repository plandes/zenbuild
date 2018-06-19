## makefile automates the application distribution for lein projects

# model
ZMODEL ?=	$$ZMODEL
MODEL_DIR=	model
GLOVE_MODEL=	$(MODEL_DIR)/glove/glove.6B.50d.txt

# application assemble
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

.PHONY: model-test
model-test:	$(MODEL_DIR)
		lein test

$(MODEL_DIR):
	@echo "creating model"
	@if [ -z "$$ZMODEL" ] ; then \
		echo "downloading model..." ; \
		make model-download ; \
	else \
		echo "linking to $$ZMODEL..." ; \
		ln -s $(ZMODEL) || true ; \
	fi

.PHONY:	model-download
model-download:
	mkdir -p $(MODEL_DIR)/stanford/pos
	wget -O $(MODEL_DIR)/model.zip http://nlp.stanford.edu/software/stanford-postagger-2015-12-09.zip && \
		cd $(MODEL_DIR) && \
		unzip model.zip && \
		mv stanford-postagger-2015-12-09/models/english-left3words-distsim.tagger stanford/pos && \
		rm -r model.zip stanford-postagger-2015-12-09
	@echo "see https://github.com/plandes/clj-nlp-parse#setup for details on model configuration"

.PHONY:	glove-model
glove-model:	$(GLOVE_MODEL)

$(GLOVE_MODEL):
	mkdir -p $(MODEL_DIR)/glove
	wget -O $(MODEL_DIR)/model.zip http://nlp.stanford.edu/data/glove.6B.zip && \
		cd $(MODEL_DIR) && \
		unzip model.zip && \
		rm model.zip && \
		mv *.txt glove

.PHONY:	models
models:	model glove-model
