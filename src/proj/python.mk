## makefile automates the build and deployment for python projects

## includes
include $(BUILD_INC)/src/mk/python.mk

.PHONY: info
info:
	echo include $(BUILD_INC)/src/mk/python.mk
	@echo "interpreter: $(PYTHON)"
	@echo "py-src: $(PY_SRC)"
	@echo "py-test: $(PY_SRC_TEST)"
	@echo "make-include: $(BUILD_INC)"
	@echo "clean: $(ADD_CLEAN)"

.PHONY:	run
run:		pytest

.PHONY:	test
test:		pytest

.PHONY:	package
package:	pypackage
