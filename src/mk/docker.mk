## docker makefile include


## User config
#
# must declare these these
#DOCKER_IMG_NAME =
#DOCKER_BUILD_OBJS =
#DOCKER_BUILD_ARGS = --build-arg var_name=${VARIABLE_NAME}
#DOCKER_CONTAINER =

## Build config
#
# docker config
DOCKER_CMD ?=		docker
DOCKER_CMP_CMD ?=	docker-compose
DOCKER_USER ?=		$(GIT_USER)
DOCKER_CONTAINER ?=	$(shell grep container_name docker-compose.yml | awk '{print $$2}')
DOCKER_PREFIX ?=	.
DOCKER_IMG_NAME ?=	$(DOCKER_CONTAINER)
DOCKER_IMG=		$(DOCKER_USER)/$(DOCKER_IMG_NAME)
DOCKER_VERSION ?=	snapshot
DOCKER_UP_DEPS ?=	dockerbuild
DOCKER_CMP_UP_ARGS ?=
DOCKER_CMP_DOWN_ARGS ?=

# system config
INFO_TARGETS +=		dockerinfo

# silence warnings on git.mk import
GIT_BUILD_INFO_BIN =	echo


## Target
##
.PHONY:		dockerinfo
dockerinfo:
		@echo "image-name: $(DOCKER_IMG_NAME)"
		@echo "image: $(DOCKER_IMG)"
		@echo "container: $(DOCKER_CONTAINER)"
		@echo "docker-version: $(DOCKER_VERSION)"

.PHONY:		dockercheckver
dockercheckver:
		$(eval DOCKER_VER_LAST_TAG := $(shell git tag -l | sort -V | tail -1 | sed 's/.//'))
		@echo $(DOCKER_VER_LAST_TAG) =? $(DOCKER_VERSION) ; [ "$(DOCKER_VER_LAST_TAG)" == "$(DOCKER_VERSION)" ]

.PHONY:		dockerbuild
dockerbuild:	$(DOCKER_BUILD_OBJS)
		$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
		$(DOCKER_CMD) build $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMG) $(DOCKER_PREFIX)
		$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VERSION)

.PHONY: 	dockerbuildnocache
dockerbuildnocache:	$(DOCKER_BUILD_OBJS)
		$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
		$(DOCKER_CMD) build --no-cache -t $(DOCKER_IMG) .
		$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VERSION)

.PHONY:		dockerpush
dockerpush:	dockerbuild
		$(DOCKER_CMD) push $(DOCKER_IMG)

.PHONY:		dockerinstall
dockerinstall:	dockercheckver
		make DOCKER_VERSION=$(GIT_VER) dockerbuild

.PHONY:		dockerrm
dockerrm:	dockerrmi
		@echo "remember to shut down the image first"
		$(DOCKER_CMD) images | grep $(DOCKER_IMG) | awk '{print $$2}' | xargs -i{} $(DOCKER_CMD) rmi $(DOCKER_IMG):{}

# remove all "orphan" images
.PHONY:		dockerrmi
dockerrmi:
		$(DOCKER_CMD) images | grep '<none>' | awk '{print $$3}' | xargs docker rmi || true

.PHONY:		dockerrmzombie
dockerrmzombie:
		for i in $$($(DOCKER_CMD) ps -a --format '{{.Names}} {{.Status}}' | \
			grep Exited | \
			awk '{print $$1}') ; do \
			$(DOCKER_CMD) rm $$i ; \
		done

.PHONY:		dockerup
dockerup:	$(DOCKER_UP_DEPS)
		$(DOCKER_CMP_CMD) up -d $(DOCKER_CMP_UP_ARGS)

.PHONY:		dockerdown
dockerdown:
		$(DOCKER_CMP_CMD) down $(DOCKER_CMP_DOWN_ARGS)

.PHONY:		dockerrestart
dockerrestart:		dockerdown dockerup

.PHONY:		dockerps
dockerps:
		$(DOCKER_CMD) ps -a

.PHONY:		dockerlogin
dockerlogin:
		$(DOCKER_CMD) exec -it $(DOCKER_CONTAINER) bash

.PHONY: dockerlog
dockerlog:
		$(DOCKER_CMD) logs $(DOCKER_CONTAINER) -f

.PHONY:		dockerstatus
dockerstatus:
		$(DOCKER_CMP_CMD) ps
