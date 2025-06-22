#@meta {author: "Paul Landes"}
#@meta {desc: "pixi enviornment invocation", date: "2025-06-22"}
#@meta {requires: "python/build.mk", order: "before"}


## Build
#
INFO_TARGETS +=		pyinvokeinfo


## Module
#
# arguments given to the pyinvoke target
PY_INVOKE_ARG ?=
# the entry point prototyping script
PY_HARNESS_BIN ?=	harness.py


## Targets
#
.PHONY:			pyinvokeinfo
pyinvokeinfo:
			@echo "py_harness_bin: $(PY_HARNESS_BIN)"

# run a command via Pixi using the ApplicationFactory class
.PHONY:			pyinvoke
pyinvoke:		$(PY_PYPROJECT_FILE)
			@$(PY_PX_BIN) run $(PY_INVOKE_ARG) invoke '$(PY_PROJECT_NAME) $(ARG)'

# run a command through the harness
.PHONY:			pyharn
pyharn:			$(PY_PYPROJECT_FILE)
			@PYTHONPATH="$${PYTHONPATH:+$${PYTHONPATH}:}src" \
				$(PY_PX_BIN) run $(PY_INVOKE_ARG) \
				python $(PY_HARNESS_BIN) $(ARG)

# invoke relpo
.PHONY:			pyinvokerelpo
pyinvokerelpo:
			@$(call relpo,$(ARG))

# print help
.PHONY:			pyhelp
pyhelp:			$(PY_PYPROJECT_FILE)
			@$(MAKE) $(PY_MAKE_ARGS) ARG="--help" pyinvoke
