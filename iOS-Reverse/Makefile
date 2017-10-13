include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iOSREWeChatView
SUBSTRATE ?= yes
iOSREWeChatView_USE_SUBSTRATE = $(SUBSTRATE)
iOSREWeChatView_FILES = Tweak.xm

ARCH = armv7 arm64
TARGET = iphone:latest:7.0
iOSREWeChatView_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
