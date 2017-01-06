# edit these
#DOCKER_IMG_NAME=
#DOCKER_OBJS=

# docker config
DOCKER_CMD=		docker
DOCKER_USER=		$(GITUSER)
DOCKER_DIST_PREFIX=	target/docker-app-dist
DOCKER_PREFIX=		target/docker-image
DOCKER_IMG_PREFIX=	$(DOCKER_PREFIX)/img
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME)

$(DOCKER_DIST_PREFIX):
	make DIST_PREFIX=$(DOCKER_DIST_PREFIX) dist

$(DOCKER_PREFIX):	$(DOCKER_DIST_PREFIX)
	mkdir -p $(DOCKER_PREFIX)
	mkdir -p $(DOCKER_IMG_PREFIX)
	cp -r $(DOCKER_DIST_PREFIX)/$(APP_NAME_REF) $(DOCKER_IMG_PREFIX)
	cp $(APP_START_SCR) $(DOCKER_IMG_PREFIX)
	cp src/docker/Dockerfile $(DOCKER_PREFIX)
	cp src/docker/$(ASBIN_NAME) $(DOCKER_IMG_PREFIX)/$(APP_SNAME_REF)/$(DIST_BIN_DNAME)

.PHONY: dockerdist
dockerdist:	$(DOCKER_PREFIX) $(DOCKER_OBJS)
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
	$(DOCKER_CMD) build -t $(DOCKER_IMG) $(DOCKER_PREFIX)
	$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(VER)

.PHONY:	dockerpush
dockerpush:	dockerdist
	$(DOCKER_CMD) push $(DOCKER_IMG)

.PHONY: dockerrm
dockerrm:
	$(DOCKER_CMD) rmi $(DOCKER_IMG):$(VER) || true
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true

.PHONY: dockerlogin
dockerlogin:
	$(DOCKER_CMD) exec -it $(DOCKER_IMG_NAME) bash

.PHONY: dockerlogs
dockerlogs:
	$(DOCKER_CMD) logs nlps -f
