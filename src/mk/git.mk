## make include file for git and GitHub integration
## PL 5/21/2020


## constants

# publicly available url of the git repo holding this build system
GIT_BUILD_REPO ?=	https://github.com/plandes/zenbuild
# location
GIT_BUILD_INFO ?=	$(MTARG)/build.json


## module

# executables
GIT_BIN ?=		git
# see bin/py-install-setup.sh
GIT_BUILD_BIN ?=	zenpybuild
# script to quickly access the build json blob
GIT_BUILD_INFO_BIN ?=	$(BUILD_BIN_DIR)/buildinfo
# get a build attribute
GIT_BUILD_ATTR ?=	$(GIT_BUILD_INFO_BIN) $(GIT_BUILD_INFO)

# all git attributes (assignment forced for other processes that use the info)
GIT_ATTR_NAMES :=	.project .user .build.tag .remotes[0].[0] .remotes[0].[1]
GIT_ATTR_VALS :=	$(shell $(GIT_BUILD_ATTR) $(GIT_ATTR_NAMES))


## git variables

# default project
GIT_PROJ ?=		$(word 1,$(GIT_ATTR_VALS))
# default git user
GIT_USER ?=		$(word 2,$(GIT_ATTR_VALS))
# current get version
GIT_VER ?=		$(word 3,$(GIT_ATTR_VALS))
# remote information for gitreinit
GIT_REMOTE_NAME ?=	$(word 4,$(GIT_ATTR_VALS))
GIT_REMOTE_URL ?=	$(word 5,$(GIT_ATTR_VALS))

## build
INFO_TARGETS +=		gitinfo


## targets

.PHONY:		gitinfo
gitinfo:
		@echo "git-bin: $(GIT_BIN)"
		@echo "git-build-util: $(GIT_BUILD_BIN)"
		@echo "git-proj: $(GIT_PROJ)"
		@echo "git-user: $(GIT_USER)"
		@echo "git-version: $(GIT_VER)"
		@echo "git-remote-name: $(GIT_REMOTE_NAME)"
		@echo "git-remote-url: $(GIT_REMOTE_URL)"

.PHONY: 	gitinit
gitinit:
		$(GIT_BIN) init .
		$(GIT_BIN) add -A :/
		$(GIT_BIN) commit -am 'initial commit'
		$(GIT_BUILD_BIN) create -m 'initial release'

.PHONY:		gitreinit
gitreinit:
		$(eval GIT_REMOTE_CMD:=git remote add $(GIT_REMOTE_NAME) $(GIT_REMOTE_URL))
#		rm -fr .git .gitmodules zenbuild
#		$(GIT_BIN) init .
#		$(GIT_BIN) submodule add $(GIT_BUILD_REPO)
#		make gitinit
		echo $(GIT_REMOTE_CMD)

.PHONY: 	gittag
gittag:
		$(GIT_BUILD_BIN) create || \
			echo "gittag installed? see bin/py-install-setup.sh"

.PHONY: 	gitforcetag
gitforcetag:
		$(GIT_BIN) add -A :/
		$(GIT_BIN) commit -am 'none' || echo "not able to commit"
		$(GIT_BUILD_BIN) recreate

.PHONY:		githubpush
githubpush:
		@echo "pushing to github"
		$(GIT_BIN) push github

.PHONY: 	gitforcepush
gitforcepush:
		$(GIT_BIN) push
		$(GIT_BIN) push --tags --force

.PHONY: 	gitnewtag
gitnewtag:
		$(GIT_BUILD_BIN) create -m '`$(GIT_BIN) log -1 --pretty=%B`'
