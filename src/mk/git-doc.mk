## make include for github document creation
## PL 2018-08-04

# This module was inspired from the how-to link:
#   https://github.com/weavejester/codox/wiki/Deploying-to-GitHub-Pages


## includes
# this requires PROJ_MODULES=git


## doc

# the default remote name to send the pages
GIT_DOC_REMOTE ?=	github
# generated and temp github pages directoreis
GIT_DOC_DIR ?=		$(MTARG)/doc/github
GIT_DOC_SRC_DIR ?=	$(GIT_DOC_DIR)/doc
GIT_DOC_DST_DIR ?=	$(GIT_DOC_DIR)/build
# dependencies before git push
GIT_DOC_PUSH_DEPS +=	$(GIT_DOC_DST_DIR)


## build
INFO_TARGETS +=		gitdocinfo


## targets
.PHONY:			gitdocinfo
gitdocinfo:
			@echo "git-doc-dir: $(GIT_DOC_DIR)"
			@echo "git-doc-src-dir: $(GIT_DOC_SRC_DIR)"
			@echo "git-doc-dst-dir: $(GIT_DOC_DST_DIR)"
			@echo "git-doc-push-deps: $(GIT_DOC_PUSH_DEPS)"

.PHONY: 		gitdocbuild
gitdocbuild:		$(GIT_DOC_DST_DIR)

# prepare the documents using GIT_DOC_SRC_DIR to trigger the doc build
$(GIT_DOC_DST_DIR):	$(GIT_DOC_SRC_DIR)
			rm -rf $(GIT_DOC_DST_DIR) && mkdir -p $(GIT_DOC_DST_DIR)
			git clone https://github.com/$(GIT_USER)/$(GIT_PROJ).git \
				$(GIT_DOC_DST_DIR)
			( cd $(GIT_DOC_DST_DIR) ; \
			  git update-ref -d refs/heads/gh-pages ; \
			  git symbolic-ref HEAD refs/heads/gh-pages ; \
			  rm .git/index ; \
			  git clean -fdx )
			cp -r $(GIT_DOC_SRC_DIR)/* $(GIT_DOC_DST_DIR)
			cp -r $(GIT_DOC_SRC_DIR)/.[a-zA-Z0-9]* $(GIT_DOC_DST_DIR)

# deploy the documentation to github
.PHONY:			gitdocdeploy
gitdocdeploy:		$(GIT_DOC_PUSH_DEPS)
			@echo "pushing to $(GIT_DOC_REMOTE)"
			git push $(GIT_DOC_REMOTE) --mirror
			( cd $(GIT_DOC_DST_DIR) ; \
			  git add . ; \
			  git commit -am "new doc push" ; \
			  git push -u origin gh-pages )
