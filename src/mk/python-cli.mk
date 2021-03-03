## make include file for executing a program on the command line
## PL 5/21/2020


## config
PY_CLI_MOD_CMD =	PY_CLI_MOD=$(shell $(GIT_BUILD_ATTR) .name)
PY_CLI_DEBUG ?=		0

## build
INFO_TARGETS +=		pycliinfo


## targets

# information
.PHONY:			pycliinfo
pycliinfo:
			@echo "py-cli-mod-cmd: $(PY_CLI_MOD_CMD)"

# display the command line help usage
.PHONY:			pyhelp
pyhelp:			$(PY_RUN_DEPS)
			@make "PYTHON_BIN_ARGS=--help" pycli

# run python clis
.PHONY:			pycli
pycli:
			$(eval $(PY_CLI_MOD_CMD))
			@if [ $(PY_CLI_DEBUG) == 1 ] ; then \
				echo "calling: $(PY_CLI_MOD).main with $(PYTHON_BIN_ARGS)" ; \
			fi
			@PYTHONPATH=$(PYTHONPATH):$(PY_SRC) $(PYTHON_BIN) -c \
			 	"from $(PY_CLI_MOD) import main; \
			 	main('$(PYTHON_BIN_ARGS)'.split())"
