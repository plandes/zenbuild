#@meta {author: "Paul Landes"}
#@meta {desc: "Git convenience and automation", date: "2020-05-21"}


## Module
#
# executables
GIT_BIN ?=		git
# publicly available url of the git repo holding this build system
GIT_BUILD_REPO ?=	https://github.com/plandes/zenbuild


## Targets
#
# initialize a new git repository
.PHONY: 	gitinit
gitinit:
		$(GIT_BIN) init .
		$(GIT_BIN) add -A :/
		@if [ ! -d zenbuild ] ; then \
			echo "creating build submodule" ; \
			$(GIT_BIN) submodule add $(GIT_BUILD_REPO) ; \
		fi
		$(GIT_BIN) commit -am 'initial commit'
		$(GIT_BIN) tag -am 'initial release' v0.0.1

# remove git data and create a nascent repository with first previous remote
.PHONY:		gitreinit
gitreinit:
		$(eval regex := 's/^([^ \t]+)\s+([^ \t]+).*/\1 \2/')
		$(eval cmd := $(GIT_BIN) remote -v | head -1 | sed -E $(regex))
		$(eval name_url := $(shell $(cmd)))
		rm -fr .git .gitmodules zenbuild
		$(GIT_BIN) init .
		$(GIT_BIN) add -A :/
		$(GIT_BIN) submodule add $(GIT_BUILD_REPO)
		$(GIT_BIN) commit -am 'initial commit'
		$(GIT_BIN) tag -am 'initial release' v0.0.1
		$(GIT_BIN) remote add $(name_url)
