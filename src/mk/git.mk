# git
GITREMOTE ?=	github
GITPROJ ?=	$(shell git remote -v | grep $(GITREMOTE) | grep push | sed -e 's:^.*/\(.*\) (push):\1:' -e 's:.git$$::')
GITUSER ?=	$(shell git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\)\/.*/\1/')

.PHONY: init
init:
	git init .
	git add -A :/
	git commit -am 'initial commit'
	$(GTAGUTIL) create -m 'initial release'

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
