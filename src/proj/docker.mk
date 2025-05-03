#@meta {author: "Paul Landes"}
#@meta {desc: "build and deployment for docker images", date: "2025-04-27"}


## Includes
#
include $(BUILD_MK_DIR)/docker/build.mk


## Targets
#
.PHONY:		build
build:		dockerbuild

.PHONY: 	deploy
deploy:		dockerpush

.PHONY:		up
up:		dockerup

.PHONY:		down
down:		dockerdown

.PHONY:		ps
ps:		dockerps

.PHONY: 	log
log:		dockerlog

.PHONY:		restart
restart:	dockerrestart

.PHONY:		login
login:		dockerlogin

.PHONY:		rmi
rmi:		dockerrmi

.PHONY:		rmzombie
rmzombie:	dockerrmzombie

.PHONY:		rmz
rmz:		dockerrmzombie
