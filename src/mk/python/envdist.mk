#@meta {author: "Paul Landes"}
#@meta {desc: "replo environment distribution", date: "2025-06-03"}
#@meta {requires: "python/build.mk", order: "before"}
#@meta {requires: "python/package.mk", order: "before"}


## Build
#
INFO_TARGETS +=		pyenvdistinfo
PY_RP_PROJ_FILES +=	zenbuild/src/relpo/envdist.yml
PY_PACKAGE_DEPS +=	$(PY_ENV_DIST_FILE)


## Module
#
PY_ENV_DIST_FILE ?=	$(PY_DIST_DIR)/$(PY_PACKAGE_NAME)-$(PY_VERSION)-envdist.tar



## Targets
#
.PHOHY:			pyenvdistinfo
pyenvdistinfo:
			@$(call loginfo,py_env_dist_file: $(PY_ENV_DIST_FILE))

# create the environment distribution file
$(PY_ENV_DIST_FILE):	$(PY_WHEEL_FILE)
			@$(call loginfo,creating env dist file: $(PY_ENV_DIST_FILE)...)
			@$(call relpo,mkenvdist -o $(PY_ENV_DIST_FILE))
pyenvdist:		$(PY_ENV_DIST_FILE)
