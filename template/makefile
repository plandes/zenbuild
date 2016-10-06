## makefile automates the build and deployment for lein projects

# edit these if you want
#GUSER=		johndoe
#APP_SCR_NAME=	${project.app.name}
#PROJ=		
#REMOTE=	origin
#DIST_PREFIX=	$(HOME)/Desktop

# location of the http://github.com/plandes/clj-zenbuild cloned directory
ZBHOME=		../clj-zenbuild

# where the stanford model files are located
#ZMODEL=	$(HOME)/opt/nlp/model

# clean the generated app assembly file
#ADD_CLEAN+=	$(ASBIN_DIR)

all:		info

include $(ZBHOME)/src/mk/compile.mk
#include $(ZBHOME)/src/mk/dist.mk
