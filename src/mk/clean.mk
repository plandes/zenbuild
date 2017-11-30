ADD_CLEAN +=		$(MTARG)
ADD_CLEAN_ALL +=	$(MTARG)

.PHONY: clean
clean:
	rm -fr $(ADD_CLEAN)
	rmdir test 2>/dev/null || true

.PHONY:	cleanall
cleanall:	clean
	rm -fr $(ADD_CLEAN_ALL)
