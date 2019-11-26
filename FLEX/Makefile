
DEBUG = false

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FLEX
FLEXLoader_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	@echo "Run FLEX dylib build script..."
	./build_dylib.sh

after-install::
	install.exec "killall -9 SpringBoard"
