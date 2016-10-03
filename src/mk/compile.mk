## makefile automates the build and deployment for lein projects

# edit these if you want
#USER=		
#APP_NAME=	
#PROJ=		
#REMOTE=		github
#DIST_PREFIX=	$(HOME)/Desktop

# defs
POM=		pom.xml
MTARG=		target
AS_DIR=		$(MTARG)/appassembler

# determine version
VER=		$(shell git tag -l | sort -V | tail -1 | sed 's/.//')
VPREF=		$(if $(VER),-$(VER),-0.1.0-SNAPSHOT)

# app assemble (maven plugin
ANRCMD=		head -1 project.clj | sed 's/(defproject \(.*\)\/\(.*\) .*/\2/'
APP_NAME_REF=	$(if $(APP_NAME),$(APP_NAME),$(shell $(ANRCMD)))
APP_SNAME_REF=	$(if $(APP_SCR_NAME),$(APP_SCR_NAME),$(APP_NAME_REF))
DIST_DIR=	$(if $(DIST_PREFIX),$(DIST_PREFIX)/$(APP_NAME_REF),$(HOME)/Desktop/$(APP_NAME_REF))
DIST_BIN_DIR=	$(DIST_DIR)/bin

# jar
LIB_JAR=	$(MTARG)/$(APP_NAME_REF)$(VPREF).jar
UBER_JAR=	$(MTARG)/$(APP_NAME_REF)$(VPREF)-standalone.jar

# git
GITREMOTE=	$(if $(REMOTE),$(REMOTE),github)
PNCMD=		git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\).git .*/\1/'
PROJ_REF=	$(if $(PROJ),$(PROJ),$(shell $(PNCMD)))
USRCMD=		git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\)\/.*/\1/'
GITUSER=	$(if $(USER),$(USER),$(shell $(USRCMD)))

# doc (codox)
DOC_DIR=	$(MTARG)/doc
ASBIN_DIR=	src/asbin

# executables
GTAGUTIL=	$(ZBHOME)/src/python/gtagutil

# targets

.PHONEY:
compile:	$(LIB_JAR)

.PHONEY:
jar:		$(LIB_JAR)

.PHONEY:
install:
	lein install

.PHONEY:
uber:		$(UBER_JAR)

.PHONEY:
dist:		$(DIST_BIN_DIR)

.PHONEY:
deploy:
	lein deploy clojars

.PHONEY:
run:
	lein run

.PHONEY:
forcetag:
	git add -A :/
	git commit -am 'none' || echo "not able to commit"
	$(GTAGUTIL) recreate

.PHONEY:
newtag:
	$(GTAGUTIL) create -m '`git log -1 --pretty=%B`'

.PHONEY:
info:
	@echo "version: $(VER)"
	@echo "project: $(PROJ_REF)"
	@echo "remote: $(GITREMOTE)"
	@echo "user: $(GITUSER)"
	@echo "jar: $(LIB_JAR)"
	@echo "uberjar: $(UBER_JAR)"
	@echo "app-script: $(APP_SNAME_REF)"
	@echo "app-dist: $(DIST_DIR)"

$(LIB_JAR):
	@echo compiling $(LIB_JAR)
	lein jar

$(UBER_JAR):
	@echo compiling $(UBER_JAR)
	lein with-profile +uberjar uberjar

$(POM):
	lein pom

$(AS_DIR):	$(POM)
	lein with-profile +appassem jar
	mvn package appassembler:assemble

$(DIST_BIN_DIR):	$(AS_DIR)
	mkdir -p $(DIST_DIR)
	cp -r target/appassembler/* $(DIST_DIR)
	[ -d $(ASBIN_DIR) ] && cp -r $(ASBIN_DIR)/* $(DIST_BIN_DIR) || true
	chmod 0755 $(DIST_BIN_DIR)/$(APP_SNAME_REF)

.PHONEY:
forcepush:
	git push
	git push --tags --force

.PHONEY:
docs:		$(DOC_DIR)

# https://github.com/weavejester/codox/wiki/Deploying-to-GitHub-Pages
$(DOC_DIR):
	rm -rf $(DOC_DIR) && mkdir -p $(DOC_DIR)
	git clone https://github.com/$(GITUSER)/$(PROJ_REF).git $(DOC_DIR)
	git update-ref -d refs/heads/gh-pages 
	git push $(GITREMOTE) --mirror
	( cd $(DOC_DIR) ; \
	  git symbolic-ref HEAD refs/heads/gh-pages ; \
	  rm .git/index ; \
	  git clean -fdx )
	lein codox

.PHONEY:
pushdocs:	$(DOC_DIR)
	( cd $(DOC_DIR) ; \
	  git add . ; \
	  git commit -am "new doc push" ; \
	  git push -u origin gh-pages )

.PHONEY:
cleandist:
	@echo "removing $(DIST_DIR)..."
	rm -fr $(DIST_DIR)

.PHONEY:
clean:
	rm -fr $(POM)* target dev-resources src/clojure/$(APP_NAME_REF)/version.clj
	rmdir test 2>/dev/null || true

.PHONEY:
cleanall:	clean cleandist
