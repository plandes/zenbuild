## make include file for running and testing in Python virtual environments
## PL 8/07/2019

# virtual environment binary
PY_VRENV_BIN ?=		virtualenv

# directory to create the virtual environment
PY_VRENV_DIR ?=		$(abspath $(shell pwd))/pyinst

# replace interpreter with virtualenv
PYTHON_BIN =		$(PY_VRENV_DIR)/bin/python3

# build setup
INFO_TARGETS +=		pyvrinfo
ADD_CLEAN_ALL +=	$(PY_VRENV_DIR)
PY_TEST_DEPS +=		virtualenv

# targets
.PHONY:			pyvrinfo
pyvrinfo:
			@echo "py-vrenv-dir: $(PY_VRENV_DIR)"
			@echo "python-bin: $(PYTHON_BIN)"
			@echo "py-test-deps: $(PY_TEST_DEPS)"

# virtual environment target
$(PY_VRENV_DIR):
			@echo "creating virtual environment in $(PY_VRENV_DIR)"
			$(PY_VRENV_BIN) $(PY_VRENV_DIR)

.PHONY:			pyvirtualenv
pyvirtualenv:		$(PY_VRENV_DIR) pydeps
