TARGET = cl0ver
XZ = $(TARGET).tar.xz
ZIP = $(TARGET).zip
INCDIR = include
MIGDIR = mig
SRCDIR = src
OBJDIR = build
LIBKERN ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
OSFMK ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
IOKIT ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Headers
IGCC ?= xcrun -sdk iphoneos gcc
IGCC_FLAGS = -arch armv7 -arch arm64 -Wall -O3 -std=c11 -miphoneos-version-min=9.0 -fmodules -I./$(SRCDIR)/lib -I./$(INCDIR) -I./$(MIGDIR) $(CFLAGS)
LD_FLAGS = -Wl,-dead_strip -L. -Wl,-pagezero_size,0x4000 -Wl,-image_base,0x100000000 $(LDFLAGS)
LD_LIBS = -framework IOKit -l$(TARGET) $(LIBS)
SIGN ?= xcrun -sdk iphoneos codesign
SIGN_FLAGS ?= -s -
MIG ?= xcrun -sdk iphoneos mig
MIG_FLAGS ?= -arch arm64 -DIOKIT -I../$(INCDIR)
LIBTOOL ?= xcrun -sdk iphoneos libtool
LIBTOOL_FLAGS ?= -static

.PHONY: all lib dist clean fullclean

all: $(TARGET)

lib: lib$(TARGET).a

dist: $(XZ) $(ZIP)

$(TARGET): lib$(TARGET).a $(INCDIR) $(MIGDIR)
	$(IGCC) -o $@ $(IGCC_FLAGS) $(LD_FLAGS) $(LD_LIBS) $(SRCDIR)/cli/*.c
	$(SIGN) $(SIGN_FLAGS) $(TARGET)

lib$(TARGET).a: $(patsubst $(SRCDIR)/lib/%.c,$(OBJDIR)/%.o,$(wildcard $(SRCDIR)/lib/*.c))
	$(LIBTOOL) $(LIBTOOL_FLAGS) -o $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/lib/%.c $(INCDIR) $(MIGDIR) | $(OBJDIR)
	$(IGCC) -c -o $@ $(IGCC_FLAGS) $<

$(INCDIR):
	mkdir $(INCDIR)
	ln -s $(IOKIT) $(INCDIR)/IOKit
	mkdir $(INCDIR)/libkern
	ln -s $(LIBKERN)/libkern/OSTypes.h $(INCDIR)/libkern/OSTypes.h
	mkdir $(INCDIR)/mach
	ln -s $(OSFMK)/mach/clock_types.defs $(INCDIR)/mach/clock_types.defs
	ln -s $(OSFMK)/mach/mach_types.defs $(INCDIR)/mach/mach_types.defs
	ln -s $(OSFMK)/mach/std_types.defs $(INCDIR)/mach/std_types.defs
	mkdir $(INCDIR)/mach/machine
	ln -s $(OSFMK)/mach/machine/machine_types.defs $(INCDIR)/mach/machine/machine_types.defs

$(MIGDIR): | $(INCDIR)
	mkdir $(MIGDIR)
	cd $(MIGDIR) && $(MIG) $(MIG_FLAGS) $(OSFMK)/device/device.defs

$(OBJDIR):
	mkdir $(OBJDIR)

$(XZ): $(TARGET)
	tar -cJf $@ $(TARGET)

$(ZIP): $(TARGET)
	zip -9 $@ $(TARGET)

clean:
	rm -rf $(TARGET) lib$(TARGET).a $(XZ) $(ZIP) $(INCDIR) $(OBJDIR)

fullclean: clean
	rm -rf $(MIGDIR)
