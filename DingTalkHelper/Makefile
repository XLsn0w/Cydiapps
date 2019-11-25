DEBUG = false

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DingTalkAssistant
DingTalkAssistant_FILES = $(wildcard MenuWindow/*.m) $(wildcard WIFI/*.m) $(wildcard GPS/*.m) Tweak.xm
DingTalkAssistant_FRAMEWORKS = SystemConfiguration

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 DingTalk"
