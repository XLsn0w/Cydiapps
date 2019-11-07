include $(THEOS)/makefiles/common.mk

TWEAK_NAME = alipaylog
alipaylog_FILES =$(wildcard *.m) Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 AlipayWallet"
