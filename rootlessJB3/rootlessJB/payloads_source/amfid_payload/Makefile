TARGET  = amfid_payload.dylib
OUTDIR ?= ../../bootstrap/bins

CC      = xcrun -sdk iphoneos cc -arch arm64
# it is injected into trust cache by code
# which only supports sha-256 signatures
LDID    = ldid2
CFLAGS  = -Wall

.PHONY: all clean

all: $(OUTDIR)/$(TARGET)

DEBUG ?= 0
ifeq ($(DEBUG), 1)
    CFLAGS += -DAMFID_PAYLOAD_DEBUG
else
    CFLAGS += -O2
endif

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OUTDIR)/$(TARGET): *.m *.c | $(OUTDIR)
	$(CC) -dynamiclib -o $@ $^ -framework Foundation $(CFLAGS)
	$(LDID) -S $@
	tar --disable-copyfile -cvf $(OUTDIR)/$(TARGET).tar -C $(OUTDIR)/ $(TARGET)
	rm $@

clean:
	rm -f $(OUTDIR)/$(TARGET)
	rm -f $(OUTDIR)/$(TARGET).tar
