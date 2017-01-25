## makefile automates the build and deployment for lein projects

# edit these if you want
#GUSER=		
#APP_NAME=	
#PROJ=		
#REMOTE=		github

# environment
LEIN=		lein

# defs
POM=		pom.xml
MTARG=		target

# determine version
VER=		$(shell git tag -l | sort -V | tail -1 | sed 's/.//')
VPREF=		$(if $(VER),-$(VER),-0.1.0-SNAPSHOT)

# application name (jars and dist)
ANRCMD=		grep '(defproject' project.clj | head -1 | sed 's/(defproject \(.*\)\/\(.*\) .*/\2/'
ANRRES=		$(shell $(ANRCMD))
APP_NAME_REF=	$(if $(APP_NAME),$(APP_NAME),$(ANRRES))
APP_SNAME_REF=	$(if $(APP_SCR_NAME),$(APP_SCR_NAME),$(APP_NAME_REF))

# jar
LIB_JAR_NAME=	$(ANRRES)$(VPREF).jar
LIB_JAR=	$(MTARG)/$(LIB_JAR_NAME)
UBER_JAR=	$(MTARG)/$(ANRRES)$(VPREF)-standalone.jar

# git
GITREMOTE=	$(if $(REMOTE),$(REMOTE),github)
PNCMD=		git remote -v | grep $(GITREMOTE) | grep push | sed -e 's:^.*/\(.*\) (push):\1:' -e 's:.git$$::'
PROJ_REF=	$(if $(PROJ),$(PROJ),$(shell $(PNCMD)))
USRCMD=		git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\)\/.*/\1/'
GITUSER=	$(if $(GUSER),$(GUSER),$(shell $(USRCMD)))

# doc
DOC_SRC_DIR=	./doc
# codox
DOC_DST_DIR=	$(MTARG)/doc

# executables
GTAGUTIL=	$(ZBHOME)/src/python/gtagutil
AWSENV=		$(ZBHOME)/src/python/awsenv

# deploy
LDEPLOY_REPO=	$(if $(DEPLOY_REPO),$(DEPLOY_REPO),NONE_SET)


# targets

.PHONY: compile
compile:	$(LIB_JAR)

.PHONY: jar
jar:		$(LIB_JAR)

.PHONY: install
install:	$(COMP_DEPS)
	$(LEIN) install

.PHONY: uber
uber:		$(UBER_JAR)

.PHONY: deploy
deploy:
	$(LEIN) deploy clojars

.PHONY: run
run:
	$(LEIN) run

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

.PHONY: info
info:
	@echo "version: $(VER)"
	@echo "comp-deps: $(COMP_DEPS)"
	@echo "project: $(PROJ_REF)"
	@echo "remote: $(GITREMOTE)"
	@echo "user: $(GITUSER)"
	@echo "jar: $(LIB_JAR)"
	@echo "uberjar: $(UBER_JAR)"
	@echo "app-script: $(APP_SNAME_REF)"
	@echo "app-dist: $(DIST_DIR)"
	@echo "deploy-repo: $(LDEPLOY_REPO)"

.PHONY: deptree
deptree:	$(POM)
	mvn dependency:tree -D verbose

$(LIB_JAR):	$(COMP_DEPS)
	@echo compiling $(LIB_JAR)
	$(LEIN) jar

$(UBER_JAR):	$(COMP_DEPS)
	@echo compiling $(UBER_JAR)
	$(LEIN) with-profile +uberjar uberjar

.PHONY: checkdep
checkdep:
	@echo compiling $(UBER_JAR)
	$(LEIN) with-profile +appassem uberjar

.PHONY: checkver
checkver:
	@( LV=$$($(LEIN) git-version) ; echo $$LV =? $(VER) ; [ "$$LV" == "$(VER)" ] )

.PHONY:	check
check:	checkdep checkver

$(POM):
	$(LEIN) pom

.PHONY: docs
docs:		$(DOC_DST_DIR)

# https://github.com/weavejester/codox/wiki/Deploying-to-GitHub-Pages
$(DOC_DST_DIR):
	rm -rf $(DOC_DST_DIR) && mkdir -p $(DOC_DST_DIR)
	git clone https://github.com/$(GITUSER)/$(PROJ_REF).git $(DOC_DST_DIR)
	git update-ref -d refs/heads/gh-pages 
	git push $(GITREMOTE) --mirror
	( cd $(DOC_DST_DIR) ; \
	  git symbolic-ref HEAD refs/heads/gh-pages ; \
	  rm .git/index ; \
	  git clean -fdx )
	if [ -d $(DOC_SRC_DIR) ] ; then cp -r $(DOC_SRC_DIR)/* $(DOC_DST_DIR) ; fi
	[ -d src/java ] && $(LEIN) javadoc
	$(LEIN) codox

.PHONY: pushdocs
pushdocs:	$(DOC_DST_DIR)
	( cd $(DOC_DST_DIR) ; \
	  git add . ; \
	  git commit -am "new doc push" ; \
	  git push -u origin gh-pages )

.PHONY: s3deploy
s3deploy:
	$(AWSENV) $(LEIN) deploy $(LDEPLOY_REPO)

.PHONY: clean
clean:
	rm -fr $(POM)* target .nrepl-port .lein-repl-history dev-resources src/clojure/$(APP_NAME_REF)/version.clj $(ADD_CLEAN)
	rmdir test 2>/dev/null || true
