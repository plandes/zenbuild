## git functionality

# git binary
GIT_BIN ?=	git
# see bin/py-install-setup.sh
GTAGUTIL ?=	zenpybuild
# default git rmeote
GITREMOTE ?=	github
# default project (todo move to gittag)
GITPROJ ?=	$(shell git remote -v | grep $(GITREMOTE) | grep push | sed -e 's:^.*/\(.*\) (push):\1:' -e 's:.git$$::')
# default git user (todo move to gittag)
GITUSER ?=	$(shell git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\)\/.*/\1/')

#GITVER_LAST_TAG=	$(shell git tag -l | sort -V | tail -1 | sed 's/.//')
GITVER ?=		$(shell git describe --match v*.* --abbrev=4 --dirty=-dirty | sed 's/^v//')

INFO_TARGETS +=	gitinfo

.PHONY:	gitinfo
gitinfo:
	@echo "git-user: $(GITUSER)"
	@echo "git-version: $(GITVER)"
	@echo "git-proj: $(GITPROJ)"

.PHONY: gitinit
gitinit:
	$(GIT_BIN) init .
	$(GIT_BIN) add -A :/
	$(GIT_BIN) commit -am 'initial commit'
	$(GTAGUTIL) create -m 'initial release'

.PHONY:	gitreinit
gitreinit:
	$(eval GIT_REMOTE:=$(shell git remote -v | head -1 | awk '{print "git remote add " $$1 " " $$2}'))
	rm -fr .git .gitmodules zenbuild
	$(GIT_BIN) init .
	$(GIT_BIN) submodule add https://github.com/plandes/zenbuild
	make gitinit
	$(GIT_REMOTE)

.PHONY: gittag
gittag:
	$(GTAGUTIL) create || echo "gittag installed? see bin/py-install-setup.sh"

.PHONY: forcetag
forcetag:
	$(GIT_BIN) add -A :/
	$(GIT_BIN) commit -am 'none' || echo "not able to commit"
	$(GTAGUTIL) recreate

.PHONY:	gitgithubpush
gitgithubpush:
	@echo "pushing to github"
	$(GIT_BIN) push github

.PHONY: forcepush
forcepush:
	$(GIT_BIN) push
	$(GIT_BIN) push --tags --force

.PHONY: newtag
newtag:
	$(GTAGUTIL) create -m '`$(GIT_BIN) log -1 --pretty=%B`'
