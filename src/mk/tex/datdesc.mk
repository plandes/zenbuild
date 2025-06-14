#@meta {author: "Paul Landes"}
#@meta {desc: "include for modules that use datdesc", date: "2025-06-13"}

# to use, add the following to the make file:
# PROJ_LOCAL_MODULES= tex-table


## Module
#
# the script to generate the latex table
TEX_DATDESC_BIN ?=	datdesc
# directory to run the program assumes the parent Python path for imports
TEX_DATDESC_WD ?=	$(abspath ..)
# Python path include
TEX_DATDESC_PY_SRC ?=	.
# default arguments to get help
TEX_DATDESC_ARGS ?=	--help


## Functions
#
# invoke the datdesc command-line program
define datdesc
	( cd $(TEX_DATDESC_WD) ; \
	   PYTHONPATH=$(TEX_DATDESC_PY_SRC) \
	   $(TEX_DATDESC_BIN) $(1) )
endef
