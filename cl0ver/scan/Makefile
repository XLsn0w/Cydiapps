TARGET = scan

.PHONY: all clean

all: $(TARGET)

$(TARGET): ../mig $(TARGET).c
	xcrun -sdk iphoneos gcc -arch armv7 -arch arm64 -o $(TARGET) $(TARGET).c -Wall -I../include -I../mig -framework Foundation -framework IOKit $(CFLAGS)
	xcrun -sdk iphoneos codesign -s - $(TARGET)

../mig:
	$(MAKE) -C .. mig

clean:
	rm -f $(TARGET)
