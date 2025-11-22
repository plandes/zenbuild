#@meta {author: "Paul Landes"}
#@meta {desc: "test automation", date: "2025-06-22"}
#@meta {requires: "python/build.mk", order: "before"}


## Build
#
INFO_TARGETS +=		pytestinfo
CLEAN_DEPS +=		pytestclean


## Module
#
# phony unit test targets
PY_TEST_TARGETS ?=	pytestprev pytestcur
# targets for the pytestall target
PY_TEST_ALL_TARGETS +=
# directory where the tests live
PY_TEST_DIR ?=		tests
# test file glob pattern
PY_TEST_GLOB ?=		test_*.py
# Python path for tests
PY_TEST_PATH ?=		$(PYTHONPATH):$(abspath .)/src


## Targets
#
.PHONY:			pytestinfo
pytestinfo:
			@echo "py_test_glob: $(PY_TEST_GLOB)"

# an set the python path to the test environment and run a command-line program
.PHONY:			pytestrun
pytestrun:		$(PY_PYPROJECT_FILE)
			$(PY_PX_BIN) install -e testcur
			$(eval pybin := $(shell $(PY_PX_BIN) info --json | jq -r \
				'.environments_info|.[]|select(.name=="testcur").prefix' ))
			@export PYTHONPATH=$(PY_TEST_PATH) \
			 export PATH="$(pybin)/bin:$(PATH)" ; $(ARG)

# run unit tests on previous Python version
.PHONY:			pytestprev
pytestprev:		$(PY_PYPROJECT_FILE)
			@PYTHONPATH=$(PY_TEST_PATH) \
			 $(PY_PX_BIN) run testprev ''$(PY_TEST_GLOB)''

# run unit tests on current Python version
.PHONY:			pytestcur
pytestcur:		$(PY_PYPROJECT_FILE)
			@PYTHONPATH=$(PY_TEST_PATH) \
			 $(PY_PX_BIN) run testcur ''$(PY_TEST_GLOB)''

# run unit tests on current version
.PHONY:			pytest
pytest:			$(PY_TEST_TARGETS)

# run unit and integration tests
.PHONY:			pytestall
pytestall:		pytest $(PY_TEST_ALL_TARGETS)


.PHONY:			pytestclean
pytestclean:
			@if [ -d tests ] ; then \
				find tests -type d -name __pycache__ -prune -exec rm -r {} \; ; \
			fi
