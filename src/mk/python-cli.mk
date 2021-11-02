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
			@make "PY_CLI_ARGS=--help" pycli

# run python clis
.PHONY:			pycli
pycli:
			$(eval $(PY_CLI_MOD_CMD))
			$(eval PY_CLI_CMD=\
				"from $(PY_CLI_MOD) import main; \
				 main('mkentry $(PY_CLI_ARGS)'.split())")
			@if [ $(PY_CLI_DEBUG) == 1 ] ; then \
				echo calling: $(PY_CLI_CMD) ; \
			fi
			@PYTHONPATH=$(PYTHONPATH):$(PY_SRC) $(PYTHON_BIN) -c $(PY_CLI_CMD)
