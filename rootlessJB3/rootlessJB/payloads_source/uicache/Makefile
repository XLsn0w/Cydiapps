TARGET  = uicache
OUTDIR ?= ../../bootstrap/bins

CC      = xcrun -sdk iphoneos cc -arch arm64
LDID    = ldid
CFLAGS  = -Wall -Wno-unused-variable -Wno-unused-function

.PHONY: all clean

all: $(OUTDIR)/$(TARGET)

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OUTDIR)/$(TARGET): *.m | $(OUTDIR)
	$(CC) -o $@ $^ -framework Foundation $(CFLAGS)
	$(LDID) -SEnt.plist $@

clean:
	rm -f $(OUTDIR)/$(TARGET)
