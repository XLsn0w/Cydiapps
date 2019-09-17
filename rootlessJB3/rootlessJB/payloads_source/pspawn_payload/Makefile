TARGET  = pspawn.dylib
OUTDIR ?= ../../bootstrap/bins

CC      = xcrun -sdk iphoneos cc -arch arm64
LDID    = ldid2
CFLAGS  = -Wall

.PHONY: all clean

all: $(OUTDIR)/$(TARGET)

DEBUG ?= 0
ifeq ($(DEBUG), 1)
    CFLAGS += -DPSPAWN_PAYLOAD_DEBUG
else
    CFLAGS += -O2
endif

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OUTDIR)/$(TARGET): launchd_payload.m fishhook.c common.c | $(OUTDIR)
	$(CC) -dynamiclib -o $@ $^ -framework Foundation $(CFLAGS)
	$(LDID) -S $@
	tar --disable-copyfile -cvf $(OUTDIR)/$(TARGET).tar -C $(OUTDIR)/ $(TARGET)
	rm $@

clean:
	rm -f $(OUTDIR)/$(TARGET)
	rm -f $(OUTDIR)/$(TARGET).tar
