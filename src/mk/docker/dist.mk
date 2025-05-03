#@meta {author: "Paul Landes"}
#@meta {desc: "docker distribution (push)", date: "2025-05-03"}
#@meta {requires: "docker/build.mk", order: "before"}


## Module
#
DOCKER_DIST_BUILD_OBJS +=
DOCKER_DIST_PREFIX =		target/docker-image
DOCKER_DIST_APP_PREFIX =	target/docker-app-dist
DOCKER_DIST_IMG_PREFIX =	$(DOCKER_DIST_PREFIX)/img
DOCKER_BUILD_OBJS +=		$(DOCKER_DIST_PREFIX) $(DOCKER_DIST_BUILD_OBJS)

# docker/build.mk
DOCKER_PREFIX =			$(DOCKER_DIST_PREFIX)
INFO_TARGETS +=			dockerdistinfo


## Targets
#
.PHONY:			dockerdistinfo
dockerdistinfo:
			@echo "docker-container: $(DOCKER_CONTAINER)"
			@echo "docker-image: $(DOCKER_IMG)"

$(DOCKER_DIST_APP_PREFIX):
			make DIST_PREFIX=$(DOCKER_DIST_APP_PREFIX) dist

$(DOCKER_DIST_PREFIX):	$(DOCKER_DIST_APP_PREFIX)
			mkdir -p $(DOCKER_DIST_PREFIX)
			mkdir -p $(DOCKER_DIST_IMG_PREFIX)
			cp -r $(DOCKER_DIST_APP_PREFIX)/$(APP_NAME_REF) $(DOCKER_DIST_IMG_PREFIX)
			[ ! -z "$(DOCKER_START_SCRIPT)" ] && cp $(DOCKER_START_SCRIPT) $(DOCKER_DIST_IMG_PREFIX) || true
			cp src/docker/Dockerfile $(DOCKER_DIST_PREFIX)
			[ -f src/docker/$(ASBIN_NAME) ] && \
				cp src/docker/$(ASBIN_NAME) \
				$(DOCKER_DIST_IMG_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME) || true

.PHONY:			dockerdistclean
dockerdistclean:
			rm -rf $(DOCKER_DIST_APP_PREFIX) $(DOCKER_DIST_PREFIX)
