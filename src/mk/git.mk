# git
GITREMOTE ?=	github
GITPROJ ?=	$(shell git remote -v | grep $(GITREMOTE) | grep push | sed -e 's:^.*/\(.*\) (push):\1:' -e 's:.git$$::')
GITUSER ?=	$(shell git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\)\/.*/\1/')

#GITVER_LAST_TAG=	$(shell git tag -l | sort -V | tail -1 | sed 's/.//')
GITVER ?=		$(shell git describe --match v*.* --abbrev=4 --dirty=-dirty | sed 's/^v//')

INFO_TARGETS +=	gitinfo

.PHONY:	gitinfo
gitinfo:
	@echo "git-user: $(GITUSER)"
	@echo "git-version: $(GITVER)"

.PHONY: gitinit
gitinit:
	git init .
	git add -A :/
	git commit -am 'initial commit'
	$(GTAGUTIL) create -m 'initial release'

.PHONY:	gitreinit
gitreinit:
	rm -fr .git .gitmodules zenbuild
	git init .
	git submodule add https://github.com/plandes/zenbuild
	make gitinit

.PHONY: tag
tag:
	$(GTAGUTIL) create

.PHONY: forcetag
forcetag:
	git add -A :/
	git commit -am 'none' || echo "not able to commit"
	$(GTAGUTIL) recreate

.PHONY: forcepush
forcepush:
	git push
	git push --tags --force

.PHONY: newtag
newtag:
	$(GTAGUTIL) create -m '`git log -1 --pretty=%B`'
