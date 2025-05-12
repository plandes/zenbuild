#@meta {author: "Paul Landes"}
#@meta {desc: "deploy Python pip packages", date: "2025-05-11"}
#@meta {requires: "python/build.mk", order: "before"}


## Module
#
# deploy
PYPI_TEST_NAME ?=	pypitest
PYPI_NON_TEST_NAME ?=	pypi
PYPI_USER ?=		pypiuser
PYPI_SIGN ?=		pypiuser@example.com


## Targets
#
# create a pip distribution and upload it
.PHONY:			pydeploy
pydeploy:		$(PY_WHEEL_FILE)
			@for url in $(PYPI_TEST_NAME) $(PYPI_NON_TEST_NAME) ; do \
			    $(PY_PYTHON_BIN) -m twine upload --non-interactive \
				--sign-with $(PYPI_SIGN) --username $(PYPI_USER) \
				--repository $$url $(PY_WHEEL_FILE) ; \
			done
