## make include for github document creation
## PL 2018-08-04


## doc

# doc
GIT_DOC_DIR ?=		$(MTARG)/git
GIT_DOC_SRC_DIR ?=	$(GIT_DOC_DIR)/doc
GIT_DOC_DST_DIR ?=	$(GIT_DOC_DIR)/build
# dependencies before git push
GIT_DOC_PUSH_DEPS +=	$(GIT_DOC_DST_DIR)

# build
INFO_TARGETS +=		gitdocinfo


# targets
.PHONY:			gitdocinfo
gitdocinfo:
			@echo "doc-src-dir: $(GIT_DOC_SRC_DIR)"
			@echo "doc-dst-dir: $(GIT_DOC_DST_DIR)"
			@echo "git-remote: $(GITREMOTE)"
			@echo "git-user: $(GITUSER)"
			@echo "git-proj: $(GITPROJ)"

.PHONY: 		gitdocbuild
gitdocbuild:		$(GIT_DOC_DST_DIR)

# https://github.com/weavejester/codox/wiki/Deploying-to-GitHub-Pages
$(GIT_DOC_DST_DIR):	$(GIT_DOC_SRC_DIR)
			rm -rf $(GIT_DOC_DST_DIR) && mkdir -p $(GIT_DOC_DST_DIR)
			git clone https://github.com/$(GITUSER)/$(GITPROJ).git $(GIT_DOC_DST_DIR)
			git update-ref -d refs/heads/gh-pages 
			( cd $(GIT_DOC_DST_DIR) ; \
			  git symbolic-ref HEAD refs/heads/gh-pages ; \
			  rm .git/index ; \
			  git clean -fdx )
			cp -r $(GIT_DOC_SRC_DIR)/* $(GIT_DOC_DST_DIR)

.PHONY: gitdocdeploy
gitdocdeploy:		$(GIT_DOC_PUSH_DEPS)
			git push $(GITREMOTE) --mirror
			( cd $(GIT_DOC_DST_DIR) ; \
			  git add . ; \
			  git commit -am "new doc push" ; \
			  git push -u origin gh-pages )
