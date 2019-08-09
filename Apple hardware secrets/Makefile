TARGET     = aprr
PARSE      = parse
IGCC       ?= xcrun -sdk iphoneos clang -arch arm64
IGCC_FLAGS ?= -Wall -O3 -ffreestanding -nostdlib -Wl,-preload -Wl,-no_uuid -Wl,-e,_entry $(CFLAGS)
CFLAGS     += -Wall -O3

.PHONY: all clean

all: $(TARGET).bin $(PARSE)

$(TARGET).bin: $(TARGET)
	vmacho -f $^ $@

$(TARGET): $(TARGET).s
	$(IGCC) -o $@ $^ $(IGCC_FLAGS)

$(PARSE): $(PARSE).c
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f $(TARGET) $(TARGET).bin $(PARSE)
