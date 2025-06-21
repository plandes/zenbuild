#@meta {author: "Paul Landes"}
#@meta {desc: "python documentation build", date: "2025-04-22"}
#@meta {requires: "python/build.mk", order: "before"}


## Build
#
INFO_TARGETS +=		pydocinfo
PY_RP_PROJ_FILES +=	zenbuild/src/template/python-doc/doc.yml


## Module
#
# build
PY_SITE_PKG_CMD ?=	$(PY_PX_BIN) run python -c \
			'import site; print(site.getsitepackages()[0])'
PY_DOC_BUILD ?=		$(MTARG)/doc/build
PY_DOC_BUILD_HTML ?=	$(PY_DOC_BUILD)/html
ifndef PY_DOC_IM_URL_CMD
PY_DOC_IM_URL_CMD :=	echo https://$(PY_GITHUB_USER).github.io
endif

# dist name (github repo or local doc sub path)
PY_DOC_DIST_NAME ?=	$(PY_PROJECT_NAME)

# deploy
ifndef PY_DOC_DEPLOY_CMD
PY_DOC_DEPLOY_CMD :=	echo "echo no upload command set--"
endif

# github
# the default remote name to send the pages
PY_GIT_DOC_REMOTE ?=	github
# generated and temp github pages directoreis
PY_GIT_DOC_DIR ?=	$(MTARG)/doc/github
PY_GIT_DOC_SRC_DIR ?=	$(MTARG)/doc/build/html
PY_GIT_DOC_DST_DIR ?=	$(PY_GIT_DOC_DIR)/build
# dependencies before git push
PY_GIT_DOC_PUSH_DEPS +=	$(PY_GIT_DOC_DST_DIR)


## Targets
#
.PHONY:			pydocinfo
pydocinfo:
			@echo "py_site_pkg_cmd: $(PY_SITE_PKG_CMD)"
			@echo "py_doc_im_url_cmd: $(PY_DOC_IM_URL_CMD)"
			@echo "py_git_doc_push_deps: $(PY_GIT_DOC_PUSH_DEPS)"


# generate site documentation
$(PY_DOC_BUILD):	pyinit
			@echo "buliding doc website"
			$(eval site_mod_path := $(shell $(PY_SITE_PKG_CMD)))
			$(eval doc_im_url := $(shell $(PY_DOC_IM_URL_CMD)))
			@RP_DOC_IM_URL=$(doc_im_url) \
				PYTHONPATH=$(site_mod_path) \
				$(call relpo,mkdoc -o $(PY_DOC_BUILD))
			touch $(PY_DOC_BUILD_HTML)/.nojekyll

# generate and render site documentation
.PHONY:			pydocshow
pydocshow:		$(PY_DOC_BUILD)
			$(RENDER_BIN) $(PY_DOC_BUILD)/html/index.html

.PHONY:			pydocdeploy
pydocdeploy:		clean $(PY_DOC_BUILD)
			$(PY_DOC_DEPLOY_CMD) $(PY_DOC_BUILD_HTML) $(PY_DOC_DIST_NAME)


## Git
#
# build the documentation using the default Git URL
$(PY_GIT_DOC_SRC_DIR):
			@( unset PY_DOC_IM_URL_CMD ; make $(PY_MAKE_ARGS) $(PY_DOC_BUILD) )

.PHONY:			pygitdochtml
pygitdochtml:		$(PY_GIT_DOC_SRC_DIR)

# prepare the documents using PY_GIT_DOC_SRC_DIR to trigger the doc build
$(PY_GIT_DOC_DST_DIR):	$(PY_GIT_DOC_SRC_DIR)
			rm -rf $(PY_GIT_DOC_DST_DIR) && mkdir -p $(PY_GIT_DOC_DST_DIR)
			git clone git@github.com:$(PY_GITHUB_USER)/$(PY_DOC_DIST_NAME).git \
				$(PY_GIT_DOC_DST_DIR)
			( cd $(PY_GIT_DOC_DST_DIR) ; \
			  git update-ref -d refs/heads/gh-pages ; \
			  git symbolic-ref HEAD refs/heads/gh-pages ; \
			  rm .git/index ; \
			  git clean -fdx )
			cp -r $(PY_GIT_DOC_SRC_DIR)/* $(PY_GIT_DOC_DST_DIR)
			cp -r $(PY_GIT_DOC_SRC_DIR)/.[a-zA-Z0-9]* $(PY_GIT_DOC_DST_DIR)

# deploy the documentation to github
.PHONY:			pygitdocdeploy
pygitdocdeploy:		clean $(PY_GIT_DOC_PUSH_DEPS)
			@echo "pushing to $(PY_GIT_DOC_REMOTE)"
			( cd $(PY_GIT_DOC_DST_DIR) ; \
			  git add . ; \
			  git commit -am "new doc push" ; \
			  git push -u origin gh-pages --force ; \
			  sleep 2 ; \
			  git commit --allow-empty -m "trigger rebuild" ; \
			  git push )
