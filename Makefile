.SUFFIXES:
    %:: SCCS/s.%
    %:: RCS/%
    %:: RCS/%,v
    %:: %,v
    %:: s.%


# General Settings
Q           ?= @

BUILDDIR    := build
CFG         ?= default
NAME        ?= naughtea
SRCDIR      := src
INSTALL_DIR := /usr/local


# Necessary variables
BINDIR      := $(BUILDDIR)/$(CFG)
BIN         := $(BINDIR)/$(NAME)
PWD         := $(shell pwd)
SRC         := $(sort $(subst $(PWD), ".", $(shell find $(SRCDIR)/ -iname '*.c')))
OBJ         := $(SRC:$(SRCDIR)/%.c=$(BINDIR)/%.o)
DEP         := $(OBJ:%.o=%.d)

# create necessary sub-dirs in build-dir
DUMMY       := $(shell mkdir -p $(sort $(dir $(OBJ))))


.PHONY: all clean cleanall

all: $(BIN)

-include $(CFG).cfg

-include $(DEP)


# handle command-line options
ifeq ($(DEBUG), 1)
    CFLAGS  += -g -DDEBUG -fno-inline-functions
else
    CFLAGS  ?= -O2 -DNDEBUG
endif

ifeq ($(VERBOSE), 1)
    CFLAGS  += -v
endif

ICON        := $(INSTALL_DIR)/share/$(NAME)/icon.jpg
CFLAGS      += -W -Wall -pedantic -I$(SRCDIR) -DNAUGHTEA_ICON="\"$(ICON)\""


#=====================================================================================================================#
#
#   INSTALL
#
#=====================================================================================================================#

install: all
	$(Q)sudo cp $(BIN) $(INSTALL_DIR)/bin/
	$(Q)sudo mkdir -p $(INSTALL_DIR)/share/$(NAME)
	$(Q)sudo cp icon.jpg $(INSTALL_DIR)/share/$(NAME)

#=====================================================================================================================#
#
#   CLEAN
#
#=====================================================================================================================#

clean:
	@echo "=>> CLEAN"
	$(Q)rm -fr "$(BINDIR)/*.{o,d}"

cleanall:
	@echo "=>> CLEANALL"
	$(Q)rm -fr "$(BINDIR)"


#=====================================================================================================================#
#
#   BINARY
#
#=====================================================================================================================#

$(BIN): $(OBJ)
	@echo "=>> LD $@"
	$(Q)$(CC) $(CFLAGS) -o $(BIN) $^


#=====================================================================================================================#
#
#   SOURCE
#
#=====================================================================================================================#

$(BINDIR)/%.o: $(SRCDIR)/%.c
	@echo "=>> $(CC) $<    ->    $@"
	$(Q)$(CC) $(CFLAGS) -c -MMD -o $@ $<
