## make include file for running and testing in Python virtual environments
## PL 8/07/2019

# virtual environment
PY_VRENV_DIR ?=		$(abspath $(shell pwd))/pyinst

# replace interpreter with virtualenv
PYTHON_BIN =		$(PY_VRENV_DIR)/bin/python3

INFO_TARGETS +=		pyvrinfo


# targets
.PHONY:			pyvrinfo
pyvrinfo:
			@echo "py-vrenv-dir: $(PY_VRENV_DIR)"
			@echo "python-bin: $(PYTHON_BIN)"

$(PY_VRENV_DIR):
			virtualenv $(PY_VRENV_DIR)

.PHONY:			virtualenv
virtualenv:		$(PY_VRENV_DIR) pydeps
