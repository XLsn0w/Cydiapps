
DEBUG = false

ARCHS = armv7 arm64
TARGET = iphone:latest:8.0
THEOS_DEVICE_IP = 192.168.220.195
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WXRedTweak
WXRedTweak_FILES = Tweak.xm
WXRedTweak_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

clean::
	rm -rf ./packages/* 

after-install::
	install.exec "killall -9 WeChat"
