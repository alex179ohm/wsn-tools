include commands.mk

OPTS    := -O2
CFLAGS  := -std=c99 $(OPTS) -fPIC -Wall
LDFLAGS :=

SRC  = $(wildcard *.c)
OBJ  = $(foreach obj, $(SRC:.c=.o), $(notdir $(obj)))
DEP  = $(SRC:.c=.d)

PREFIX  ?= /usr/local
BIN     ?= /bin

CFLAGS += -DVERSION="\"$(shell cat VERSION)\""

commit = $(shell ./hash.sh)
ifneq ($(commit), UNKNOWN)
	CFLAGS += -DCOMMIT="\"$(commit)\""
	CFLAGS += -DPARTIAL_COMMIT="\"$(shell echo $(commit) | cut -c1-8)\""
endif

ifndef DISABLE_DEBUG
CFLAGS += -ggdb
else
CFLAGS += -DNDEBUG=1
endif

.PHONY: all clean

all: wsn-sniffer-cli

wsn-sniffer-cli: $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) -Wp,-MMD,$*.d -c $(CFLAGS) -o $@ $<

clean:
	$(RM) $(DEP)
	$(RM) $(OBJ)
	$(RM) $(CATALOGS)
	$(RM) wsn-sniffer-cli

install:
	$(MKDIR) -p $(DESTDIR)/$(PREFIX)/$(BIN)
	$(INSTALL_PROGRAM) wsn-sniffer-cli $(DESTDIR)/$(PREFIX)/$(BIN)

uninstall:
	$(RM) $(DESTDIR)/$(PREFIX)/wsn-sniffer-cli

-include $(DEP)

