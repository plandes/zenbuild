## docker makefile include

# must declare these these
#DOCKER_IMG_NAME=
#DOCKER_OBJS=
#DOCKER_CONTAINER=

# docker config
DOCKER_CMD ?=		docker
DOCKER_USER ?=		$(GITUSER)
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME)
DOCKER_CONTAINER ?=	$(shell grep container_name docker-compose.yml | awk '{print $$2}')
INFO_TARGETS +=		dockerinfo

.PHONY: dockerinfo
dockerinfo:
	@echo "image: $(DOCKER_IMG)"
	@echo "container: $(DOCKER_CONTAINER)"

.PHONY: dockerbuild
dockerbuild:	$(DOCKER_OBJS)
	$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
	$(DOCKER_CMD) build -t $(DOCKER_IMG) .
	$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(VER)

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
