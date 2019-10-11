GO_EASY_ON_ME = 1
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = fkwechatzan
$(TWEAK_NAME)_FILES = $(wildcard *.m) Morezan.xm Tweak.xm
$(TWEAK_NAME)_CFLAGS = -Wno-implicit-function-declaration
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
