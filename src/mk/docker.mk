## docker makefile include

# must declare these these
#DOCKER_IMG_NAME=
#DOCKER_OBJS=
#DOCKER_CONTAINER=

# docker config
DOCKER_CMD ?=		docker
DOCKER_CMP_CMD ?=	docker-compose
DOCKER_USER ?=		$(GITUSER)
DOCKER_CONTAINER ?=	$(shell grep container_name docker-compose.yml | awk '{print $$2}')
DOCKER_IMG_NAME ?=	$(DOCKER_CONTAINER)
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME)
DOCKER_VERSION ?=	$(GITVER)

INFO_TARGETS +=		dockerinfo

.PHONY: dockerinfo
dockerinfo:
	@echo "image-name: $(DOCKER_IMG_NAME)"
	@echo "image: $(DOCKER_IMG)"
	@echo "container: $(DOCKER_CONTAINER)"
	@echo "docker-version: $(DOCKER_VERSION)"

.PHONY: dockerbuild
dockerbuild:	$(DOCKER_OBJS)
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
	$(DOCKER_CMD) build -t $(DOCKER_IMG) .
	$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VERSION)

.PHONY: dockerbuildnocache
dockerbuildnocache:	$(DOCKER_OBJS)
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
	$(DOCKER_CMD) build --no-cache -t $(DOCKER_IMG) .
	$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VERSION)

.PHONY:	dockerpush
dockerpush:	dockerbuild
	$(DOCKER_CMD) push $(DOCKER_IMG)

.PHONY:	dockersnapshot
dockersnapshot:
	VER=snapshot make dockerbuild

.PHONY:	dockerrmsnapshot
dockerrmsnapshot:
	$(DOCKER_CMD) rmi $(DOCKER_IMG):snapshot || true

.PHONY: dockerrm
dockerrm:	dockerrmsnapshot dockerrmi
	$(DOCKER_CMD) rmi $(DOCKER_IMG):$(DOCKER_VERSION) || true
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true

# remove all "orphan" images
.PHONY:	dockerrmi
dockerrmi:
	$(DOCKER_CMD) images | grep '<none>' | awk '{print $$3}' | xargs docker rmi || true

.PHONY:	dockerrmzombie
dockerrmzombie:
	$(DOCKER_CMD) ps -a --format '{{.Names}} {{.Status}}' | \
		grep Exited | \
		awk '{print $1}' | \
		xargs $(DOCKER_CMD) rm

.PHONY:	dockerup
dockerup:	dockerbuild
	$(DOCKER_CMP_CMD) up -d

.PHONY:	dockerdown
dockerdown:
	$(DOCKER_CMP_CMD) down

.PHONY:	dockerrestart
dockerrestart:	dockerdown dockerup

.PHONY: dockerlogin
dockerlogin:
	$(DOCKER_CMD) exec -it $(DOCKER_CONTAINER) bash

.PHONY: dockerlog
dockerlog:
	$(DOCKER_CMD) logs $(DOCKER_CONTAINER) -f

.PHONY:	dockerstatus
dockerstatus:
	$(DOCKER_CMP_CMD) ps
