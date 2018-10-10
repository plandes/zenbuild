# include resources in python package (wheel/egg)
# adding the resources also requires `package_names=['zensols', 'resources']`
# in setup.py (see zotsite project)

MTARG_PYDIST_RES=	$(MTARG_PYDIST_BDIR)/zensols/mkmeme
PY_RESOURCES +=		resources
