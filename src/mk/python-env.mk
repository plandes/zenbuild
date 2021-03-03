## make include file for creating build environment

# This creates build environment make configuration file from the zensols
# Python application configuration file.  The command line module needs an
# `export` action that prints out the environment in make syntax.

## PROJ_MODULES needs to have python-cli.mk in the list before this include


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
			$(eval PYTHON_BIN_ARGS += export --expfmt \
				make --output $(PY_CONF_ENV_FILE))
			$(eval $(PY_CLI_MOD_CMD))
			@if [ $(PY_CLI_DEBUG) == 1 ] ; then \
				echo "calling: $(PY_CLI_MOD).main with $(PYTHON_BIN_ARGS)" ; \
			fi
			@PYTHONPATH=$(PYTHONPATH):$(PY_SRC) $(PYTHON_BIN) -c \
			 	"from $(PY_CLI_MOD) import main; \
			 	main('$(PYTHON_BIN_ARGS)'.split())" \

# display the contents of the make include
.PHONY:			pyenvshow
pyenvshow:		$(PY_CONF_ENV_FILE)
			@if [ $(PY_CLI_DEBUG) == 1 ] ; then \
				echo "file: $(PY_CONF_ENV_FILE)" ; \
			fi
			@cat $(PY_CONF_ENV_FILE)
