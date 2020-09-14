## make include file for creating build environment

# This creates build environment make configuration file from the zensols
# Python application configuration file.  The command line module needs an
# `env` action that prints out the environment in make syntax.

## PL 5/25/2020


# environment
PY_CONF_ENV_DIR =	$(MTARG)/mk
PY_CONF_ENV_FILE =	$(PY_CONF_ENV_DIR)/env.mk

# this actually works with GNU make; it knows to include it after it is created
# even though it complains about it on the first pass
include $(PY_CONF_ENV_FILE)

## python

# run the command line directory (assume standard CLI zensols.util boilerplate)
.PHONY:			pyenv
pyenv:			$(PY_CONF_ENV_FILE)

# create build environment make configuration file
$(PY_CONF_ENV_FILE):
			mkdir -p $(PY_CONF_ENV_DIR)
			@echo "source build for Python module name"
			$(eval $(PY_MOD_CMD))
			@echo "calling: $(PY_CLI_MOD).$(PY_CLI_CLASS) with $(PYTHON_BIN_ARGS) env"
			@PYTHONPATH=$(PYTHONPATH):$(PY_SRC) $(PYTHON_BIN) -c \
				"from $(PY_CLI_MOD) import $(PY_CLI_CLASS); \
				$(PY_CLI_CLASS)().invoke( \
				'$(PYTHON_BIN_ARGS) env'.split())" \
				> $(PY_CONF_ENV_FILE)

# display the contents of the make include
.PHONY:			pyenvshow
pyenvshow:		$(PY_CONF_ENV_FILE)
			cat $(PY_CONF_ENV_FILE)
