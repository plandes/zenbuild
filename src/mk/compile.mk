## makefile automates the build and deployment for lein projects

# edit these if you want
#GUSER=		
#APP_NAME=	
#PROJ=		
#REMOTE=		github

# defs
POM=		pom.xml
MTARG=		target
AS_DIR=		$(MTARG)/appassembler

# determine version
VER=		$(shell git tag -l | sort -V | tail -1 | sed 's/.//')
VPREF=		$(if $(VER),-$(VER),-0.1.0-SNAPSHOT)

# jar
LIB_JAR=	$(MTARG)/$(APP_NAME_REF)$(VPREF).jar
UBER_JAR=	$(MTARG)/$(APP_NAME_REF)$(VPREF)-standalone.jar

# git
GITREMOTE=	$(if $(REMOTE),$(REMOTE),github)
PNCMD=		git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\).git .*/\1/'
PROJ_REF=	$(if $(PROJ),$(PROJ),$(shell $(PNCMD)))
USRCMD=		git remote -v | grep $(GITREMOTE) | grep push | sed 's/.*\/\(.*\)\/.*/\1/'
GITUSER=	$(if $(GUSER),$(GUSER),$(shell $(USRCMD)))

# doc (codox)
DOC_DIR=	$(MTARG)/doc

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

.PHONEY:
checkdep:
	@echo compiling $(UBER_JAR)
	lein with-profile +appassem uberjar

$(POM):
	lein pom

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
clean:
	rm -fr $(POM)* target dev-resources src/clojure/$(APP_NAME_REF)/version.clj $(ADD_CLEAN)
	rmdir test 2>/dev/null || true
