## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/docker.mk

.PHONY:	build
build:		dockerbuild

.PHONY: deploy
deploy:		dockerpush

.PHONY:	up
up:		dockerup

.PHONY:	down
down:		dockerdown

.PHONY:	ps
ps:		dockerps

.PHONY: log
log:		dockerlog

.PHONY:	restart
restart:	dockerrestart

.PHONY:	login
login:		dockerlogin

.PHONY:	rmi
rmi:		dockerrmi

.PHONY:	rmzombie
rmzombie:	dockerrmzombie

.PHONY:	rmz
rmz:		dockerrmzombie
