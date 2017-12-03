# edit these
#DOCKER_IMG_NAME=
#DOCKER_OBJS=
#DOCKER_CONTAINER=

# docker config
DOCKER_CMD=		docker
DOCKER_USER=		$(GITUSER)
DOCKER_DIST_PREFIX=	target/docker-app-dist
DOCKER_PREFIX=		target/docker-image
DOCKER_IMG_PREFIX=	$(DOCKER_PREFIX)/img
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME)
DOCKER_CONTAINER ?=	$(shell grep container_name docker-compose.yml | awk '{print $$2}')
INFO_TARGETS +=		dockerinfo

.PHONY: dockerinfo
dockerinfo:
	@echo "container: $(DOCKER_CONTAINER)"

$(DOCKER_DIST_PREFIX):
	make DIST_PREFIX=$(DOCKER_DIST_PREFIX) dist

$(DOCKER_PREFIX):	$(DOCKER_DIST_PREFIX)
	mkdir -p $(DOCKER_PREFIX)
	mkdir -p $(DOCKER_IMG_PREFIX)
	cp -r $(DOCKER_DIST_PREFIX)/$(APP_NAME_REF) $(DOCKER_IMG_PREFIX)
	[ ! -z "$(DOCKER_START_SCR)" ] && cp $(DOCKER_START_SCR) $(DOCKER_IMG_PREFIX) || true
	cp src/docker/Dockerfile $(DOCKER_PREFIX)
	[ -f src/docker/$(ASBIN_NAME) ] && cp src/docker/$(ASBIN_NAME) $(DOCKER_IMG_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME) || true

.PHONY: dockerprep
dockerprep:		$(DOCKER_PREFIX)

.PHONY: dockerdist
dockerdist:	$(DOCKER_PREFIX) $(DOCKER_OBJS)
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
	$(DOCKER_CMD) build -t $(DOCKER_IMG) $(DOCKER_PREFIX)
	$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(VER)

.PHONY:	dockerpush
dockerpush:	dockerdist
	$(DOCKER_CMD) push $(DOCKER_IMG)

.PHONY:	dockersnapshot
dockersnapshot:
	VER=snapshot make dockerdist

.PHONY:	dockerrmsnapshot
dockerrmsnapshot:
	$(DOCKER_CMD) rmi $(DOCKER_IMG):snapshot || true

.PHONY: dockerrm
dockerrm:
	$(DOCKER_CMD) rmi $(DOCKER_IMG):$(VER) || true
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true

# remove all "orphan" images
.PHONY:	dockerrmi
dockerrmi:
	$(DOCKER_CMD) images | grep '<none>' | awk '{print $$3}' | xargs docker rmi || true

.PHONY: dockerlogin
dockerlogin:
	$(DOCKER_CMD) exec -it $(DOCKER_IMG_NAME) bash

.PHONY: dockerlogs
dockerlogs:
	$(DOCKER_CMD) logs $(DOCKER_CONTAINER) -f

.PHONY: dockerclean
dockerclean:
	rm -rf $(DOCKER_DIST_PREFIX)
