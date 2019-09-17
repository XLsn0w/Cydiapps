TARGET  = jailbreakd_client
OUTDIR ?= bin

CC      = xcrun -sdk iphoneos cc -arch arm64
LDID    = ldid
CFLAGS  = -Wall

.PHONY: all clean

all: $(OUTDIR)/$(TARGET)

DEBUG ?= 0
ifeq ($(DEBUG), 1)
    CFLAGS += -DJAILBREAKD_CLIENT_DEBUG
else
    CFLAGS += -O2
endif

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OUTDIR)/$(TARGET): jailbreakd_client.m | $(OUTDIR)
	$(CC) -o $@ $^ -framework Foundation $(CFLAGS)
	$(LDID) -SEnt.plist $@

clean:
	rm -f $(OUTDIR)/$(TARGET)
