#@meta {author: "Paul Landes"}
#@meta {desc: "ANSI C program compilation", date: "2018-09-26"}


## Module
#
# compliation
SRC_DIR ?=		src
INC_DIR ?=		$(SRC_DIR)
CC ?=			gcc
LDIR ?=			../lib
CFLAGS ?=		-I$(INC_DIR)

# build setup
CPROG_BIN ?=		$(MTARG)/$(CPROG)
CPROG_INST_DIR ?=	$(APP_INST_DIR)

# objects
OBJ_NAMES =		$(patsubst %.c,%.o,$(notdir $(wildcard $(SRC_DIR)/*.c)))
OBJ +=			$(addprefix $(MTARG)/,$(OBJ_NAMES))

# headers
HEADERS +=		$(wildcard $(INC_DIR)/*.h)
DEPS +=			$(MTARG) $(HEADERS)

# info
INFO_TARGETS +=		cinfo
ADD_CLEAN_ALL +=	$(CPROG_INST_DIR)


## Targets
#
# C make build information
.PHONY:			cinfo
cinfo:
			@echo "program_name: $(CPROG)"
			@echo "program_binary: $(CPROG_BIN)"
			@echo "headers: $(HEADERS)"
			@echo "obj: $(OBJ)"
			@echo "deps: $(DEPS)"

# all derived objects
$(MTARG):
			mkdir -p $(MTARG)

# compile object files
$(MTARG)/%.o:		$(SRC_DIR)/%.c $(DEPS)
			$(CC) -c -o $@ $< $(CFLAGS)

$(CPROG_BIN):		$(OBJ)
			$(CC) -o $@ $^ $(CFLAGS)

# easy targ compile the program
.PHONY:			compile
compile:		$(CPROG_BIN)

# compile and run with args
.PHONY:			run
run:			$(CPROG_BIN)
			$(CPROG_BIN) $(CPROG_RUN_ARGS)

# compile and install in a new directory (defaults to ./inst)
.PHONY:			install
install:		$(CPROG_BIN)
			mkdir -p $(CPROG_INST_DIR)
			cp $(CPROG_BIN) $(CPROG_INST_DIR)
