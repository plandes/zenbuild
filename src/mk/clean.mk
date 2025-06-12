#@meta {author: "Paul Landes"}
#@meta {desc: "shared clean config and targets", date: "2025-04-17"}


## Build
#
CLEAN_DEPS +=
CLEAN_ALL_DEPS +=	clean
VAPORIZE_DEPS +=	cleanall

ADD_CLEAN +=		$(MTARG)
ADD_CLEAN_ALL +=
ADD_VAPORIZE +=

INFO_TARGETS +=		cleaninfo


## Targets
#
# report variables
.PHONY:			cleaninfo
cleaninfo:
			@echo "add-clean: $(ADD_CLEAN)"
			@echo "add-clean-all: $(ADD_CLEAN_ALL)"
			@echo "add-vaporize: $(ADD_VAPORIZE)"

# harmless clean
.PHONY:			clean
clean:			$(CLEAN_DEPS)
			@echo "removing: $(ADD_CLEAN)"
			@rm -fr $(ADD_CLEAN)

# dangerous clean
.PHONY:			cleanall
cleanall:		$(CLEAN_ALL_DEPS)
			@if [ ! -z "$(ADD_CLEAN_ALL)" ] ; then \
				echo "removing: $(ADD_CLEAN_ALL)" ; \
				rm -fr $(ADD_CLEAN_ALL) ; \
			fi

# very dangerous clean
.PHONY:			vaporize
vaporize:		$(VAPORIZE_DEPS)
			@if [ ! -z "$(ADD_VAPORIZE)" ] ; then \
				echo "removing: $(ADD_VAPORIZE)" ; \
				rm -fr $(ADD_VAPORIZE) ; \
			fi
