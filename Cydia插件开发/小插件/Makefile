include $(THEOS)/makefiles/common.mk

ARCHS = armv7 arm64

TWEAK_NAME = YourViewing
YourViewing_FILES = Tweak.xm
YourViewing_LIBRARIES = applist
YourViewing_FRAMEWORKS = UIKit Foundation CoreGraphics CoreGraphics QuartzCore CoreServices CFNetwork
YourViewing_LDFLAGS = -lz

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
