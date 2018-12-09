## make include for github document creation
## PL 2018-08-04

# doc
DOC_SRC_DIR=	./doc
# codox
DOC_DST_DIR=	$(MTARG)/doc
# dependencies before git push
DOC_PUSH_DEPS +=$(DOC_DST_DIR)


# targets
.PHONY: 	docbuild
docbuild:	$(DOC_DST_DIR)

# https://github.com/weavejester/codox/wiki/Deploying-to-GitHub-Pages
$(DOC_DST_DIR):
		rm -rf $(DOC_DST_DIR) && mkdir -p $(DOC_DST_DIR)
		git clone https://github.com/$(GITUSER)/$(GITPROJ).git $(DOC_DST_DIR)
		git update-ref -d refs/heads/gh-pages 
		( cd $(DOC_DST_DIR) ; \
		  git symbolic-ref HEAD refs/heads/gh-pages ; \
		  rm .git/index ; \
		  git clean -fdx )
		if [ -d $(DOC_SRC_DIR) ] ; then cp -r $(DOC_SRC_DIR)/* $(DOC_DST_DIR) ; fi

.PHONY: docdeploy
docdeploy:	$(DOC_PUSH_DEPS)
		git push $(GITREMOTE) --mirror
		( cd $(DOC_DST_DIR) ; \
		  git add . ; \
		  git commit -am "new doc push" ; \
		  git push -u origin gh-pages )
