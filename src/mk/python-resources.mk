# include resources in python package (wheel/egg)
# adding the resources also requires `package_names=['zensols', 'resources']`
# in setup.py (see zotsite project)

# guesing the python package to put the resources (so that when unzipped
# accessible by pkg_resources), which works on a zensols python boilerplate
# template
PY_PKG_DIR=		$(shell ls $(PY_SRC)/ | tail -1)/$(shell ls $(PY_SRC)/*/ | tail -1)

# where to copy the resources that is zipped up by setup tools
MTARG_PYDIST_RES=	$(MTARG_PYDIST_BDIR)/$(PY_PKG_DIR)
