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
DOCKER_VERSION ?=	snapshot
DOCKER_BUILD_DEPS ?=	dockerbuild

INFO_TARGETS +=		dockerinfo

.PHONY: dockerinfo
dockerinfo:
	@echo "image-name: $(DOCKER_IMG_NAME)"
	@echo "image: $(DOCKER_IMG)"
	@echo "container: $(DOCKER_CONTAINER)"
	@echo "docker-version: $(DOCKER_VERSION)"

.PHONY:	dockercheckver
dockercheckver:
	$(eval DOCKER_VER_LAST_TAG := $(shell git tag -l | sort -V | tail -1 | sed 's/.//'))
	@echo $(DOCKER_VER_LAST_TAG) =? $(DOCKER_VERSION) ; [ "$(DOCKER_VER_LAST_TAG)" == "$(DOCKER_VERSION)" ]

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

.PHONY:	dockerinstall
dockerinstall:	dockercheckver
	make DOCKER_VERSION=$(GITVER) dockerbuild

.PHONY: dockerrm
dockerrm:	dockerrmi
	@echo "remember to shut down the image first"
	$(DOCKER_CMD) images | grep $(DOCKER_IMG) | awk '{print $$2}' | xargs -i{} $(DOCKER_CMD) rmi $(DOCKER_IMG):{}

# remove all "orphan" images
.PHONY:	dockerrmi
dockerrmi:
	$(DOCKER_CMD) images | grep '<none>' | awk '{print $$3}' | xargs docker rmi || true

.PHONY:	dockerrmzombie
dockerrmzombie:
	for i in $$($(DOCKER_CMD) ps -a --format '{{.Names}} {{.Status}}' | \
		grep Exited | \
		awk '{print $$1}') ; do \
		$(DOCKER_CMD) rm $$i ; \
	done

.PHONY:	dockerup
dockerup:	$(DOCKER_BUILD_DEPS)
	$(DOCKER_CMP_CMD) up -d

.PHONY:	dockerdown
dockerdown:
	$(DOCKER_CMP_CMD) down

.PHONY:	dockerrestart
dockerrestart:	dockerdown dockerup

.PHONY:	dockerps
dockerps:
	$(DOCKER_CMD) ps -a

.PHONY: dockerlogin
dockerlogin:
	$(DOCKER_CMD) exec -it $(DOCKER_CONTAINER) bash

.PHONY: dockerlog
dockerlog:
	$(DOCKER_CMD) logs $(DOCKER_CONTAINER) -f

.PHONY:	dockerstatus
dockerstatus:
	$(DOCKER_CMP_CMD) ps
