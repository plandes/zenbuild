## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/python.mk

.PHONY: info
info:	envinfo
	@echo "interpreter: $(PYTHON)"
	@echo "py-src: $(PY_SRC)"
	@echo "py-test: $(PY_SRC_TEST)"
	@echo "clean: $(ADD_CLEAN)"

.PHONY:	run
run:		pytest

.PHONY:	test
test:		pytest

.PHONY:	package
package:	pypackage
