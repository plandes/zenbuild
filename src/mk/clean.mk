CLEAN_DEPS +=
CLEAN_ALL_DEPS +=	clean
ADD_CLEAN +=		$(MTARG)
ADD_CLEAN_ALL +=	$(MTARG)
INFO_TARGETS +=		cleaninfo

.PHONY:			cleaninfo
cleaninfo:
			@echo "add-clean: $(ADD_CLEAN)"
			@echo "add-clean-all: $(ADD_CLEAN_ALL)"

.PHONY:			clean
clean:			$(CLEAN_DEPS)
			rm -fr $(ADD_CLEAN)
			rmdir test 2>/dev/null || true

.PHONY:			cleanall
cleanall:		$(CLEAN_ALL_DEPS)
			rm -fr $(ADD_CLEAN_ALL)
