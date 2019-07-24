TARGET = sock_port

.PHONY: all clean

all: clean
	xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO PRODUCT_BUNDLE_IDENTIFIER="com.jakeashacks.sock-port" -sdk iphoneos -configuration Debug
	ln -sf build/Debug-iphoneos Payload
	zip -r9 $(TARGET).ipa Payload/$(TARGET).app

clean:
	rm -rf build Payload $(TARGET).ipa
