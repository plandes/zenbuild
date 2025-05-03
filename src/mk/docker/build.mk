#@meta {author: "Paul Landes"}
#@meta {desc: "docker makefile include", date: "2025-05-03"}


## Project
#
# must set these in the make file
#DOCKER_IMG_NAME =
#DOCKER_BUILD_OBJS =
#DOCKER_BUILD_ARGS = --build-arg var_name=${VARIABLE_NAME}
#DOCKER_CONTAINER =


## Module
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
DOCKER_PRE_UP_ARGS ?=	--ansi never
DOCKER_PRE_DOWN_ARGS ?=	--ansi never
DOCKER_CMP_UP_ARGS ?=
DOCKER_CMP_DOWN_ARGS ?=


## Build
#
# system config
INFO_TARGETS +=		dockerinfo


## Target
##
.PHONY:		dockerinfo
dockerinfo:
		@echo "image-name: $(DOCKER_IMG_NAME)"
		@echo "image: $(DOCKER_IMG)"
		@echo "container: $(DOCKER_CONTAINER)"
		@echo "docker-version: $(DOCKER_VERSION)"

.PHONY:		dockersettag
dockersettag:
		$(eval DOCKER_VER_LAST_TAG := $(shell git tag -l | sort -V | tail -1 | sed 's/^v//'))

# make a new docker tag
.PHONY:		dockermktag
dockermktag:	dockersettag
		@if [ -z "$(DOCKER_VER_LAST_TAG)" ] ; then \
			echo "no git tag" ; \
			exit 1 ; \
		fi
		$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VER_LAST_TAG)

# check the set version again the git version
.PHONY:		dockercheckver
dockercheckver:	dockersettag
		@echo $(DOCKER_VER_LAST_TAG) =? $(DOCKER_VERSION) ; \
			[ "$(DOCKER_VER_LAST_TAG)" == "$(DOCKER_VERSION)" ]

# build the docker image from the Dockerfil
.PHONY:		dockerbuild
dockerbuild:	$(DOCKER_BUILD_OBJS)
		$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
		$(DOCKER_CMD) build $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMG) $(DOCKER_PREFIX)
		$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VERSION)

# build the image from scratch without intermediate caches
.PHONY: 	dockerbuildnocache
dockerbuildnocache:	$(DOCKER_BUILD_OBJS)
		$(DOCKER_CMD) rmi $(DOCKER_IMG) || true
		$(DOCKER_CMD) build --no-cache -t $(DOCKER_IMG) .
		$(DOCKER_CMD) tag $(DOCKER_IMG) $(DOCKER_IMG):$(DOCKER_VERSION)

# push the build docker image to dockerhub
.PHONY:		dockerpush
dockerpush:	dockerbuild
		$(DOCKER_CMD) push $(DOCKER_IMG)

# push the tagged docker image to dockerhub (use dockermktag first)
.PHONY:		dockerpushtag
dockerpushtag:	dockersettag
		$(DOCKER_CMD) push $(DOCKER_IMG):$(DOCKER_VER_LAST_TAG)

# remove the docker image from the local image library
.PHONY:		dockerrm
dockerrm:	dockerrmi
		@echo "remember to shut down the image first"
		$(DOCKER_CMD) images | grep $(DOCKER_IMG) | awk '{print $$2}' | xargs -i{} $(DOCKER_CMD) rmi $(DOCKER_IMG):{}

# remove all "orphan" images
.PHONY:		dockerrmi
dockerrmi:
		$(DOCKER_CMD) images | grep '<none>' | awk '{print $$3}' | xargs docker rmi || true

# remove all complete containers that are no long running (only logs available)
.PHONY:		dockerrmzombie
dockerrmzombie:
		for i in $$($(DOCKER_CMD) ps -a --format '{{.Names}} {{.Status}}' | \
			grep Exited | \
			awk '{print $$1}') ; do \
			$(DOCKER_CMD) rm $$i ; \
		done

# start the container
.PHONY:		dockerup
dockerup:	$(DOCKER_UP_DEPS)
		$(DOCKER_CMP_CMD) $(DOCKER_PRE_UP_ARGS) \
			up -d $(DOCKER_CMP_UP_ARGS)

# stop the container
.PHONY:		dockerdown
dockerdown:
		$(DOCKER_CMP_CMD) $(DOCKER_PRE_DOWN_ARGS) \
			down $(DOCKER_CMP_DOWN_ARGS)

# restart the container
.PHONY:		dockerrestart
dockerrestart:		dockerdown dockerup

# list all running containers
.PHONY:		dockerps
dockerps:
		$(DOCKER_CMD) ps -a

# login to the the container as root
.PHONY:		dockerlogin
dockerlogin:
		$(DOCKER_CMD) exec -it $(DOCKER_CONTAINER) bash

# dump the standard output/log of the container
.PHONY:		dockerlog
dockerlog:
		$(DOCKER_CMD) logs $(DOCKER_CONTAINER) -f
