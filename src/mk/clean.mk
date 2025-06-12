#@meta {author: "Paul Landes"}
#@meta {desc: "shared clean config and targets", date: "2025-04-17"}


## Build
#
CLEAN_DEPS +=
CLEAN_ALL_DEPS +=	clean

ADD_CLEAN +=		$(MTARG)
ADD_CLEAN_ALL +=	$(MTARG)

INFO_TARGETS +=		cleaninfo


## Targets
#
.PHONY:			cleaninfo
cleaninfo:
			@echo "add-clean: $(ADD_CLEAN)"
			@echo "add-clean-all: $(ADD_CLEAN_ALL)"

.PHONY:			clean
clean:			$(CLEAN_DEPS)
			@echo "removing: $(ADD_CLEAN)"
			@rm -fr $(ADD_CLEAN)

.PHONY:			cleanall
cleanall:		$(CLEAN_ALL_DEPS)
			@echo "removing: $(ADD_CLEAN_ALL)"
			@rm -fr $(ADD_CLEAN_ALL)
