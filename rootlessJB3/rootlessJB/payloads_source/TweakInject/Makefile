ARCHS=arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TweakInject
TweakInject_FILES = TweakInject.xm fishhook.c
TweakInject_USE_SUBSTRATE=0

CFLAGS += -Wno-c++11-compat-deprecated-writable-strings

include $(THEOS_MAKE_PATH)/tweak.mk
