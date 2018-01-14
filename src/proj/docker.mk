## makefile automates the build and deployment for python projects

## includes
include $(BUILD_MK_DIR)/docker.mk

.PHONY:	build
build:		dockersnapshot

.PHONY:	compile
compile:	dockersnapshot

.PHONY:	install
install:	dockerinstall

.PHONY: deploy
deploy:		dockerpush

.PHONY:	up
up:		dockerup

.PHONY:	down
down:		dockerdown

.PHONY: log
log:		dockerlog

.PHONY:	restart
restart:	dockerrestart

.PHONY:	login
login:		dockerlogin
