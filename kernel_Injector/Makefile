ARCHS ?= arm64 arm64e
target ?= iphone:latest:11.0
CFLAGS = -Iinclude
GO_EASY_ON_ME=1
FINALPACKAGE=1
include $(THEOS)/makefiles/common.mk 

TOOL_NAME = inject
inject_CODESIGN_FLAGS = -Sentitlements.xml
inject_CFLAGS += -I. -I./patchfinder64 -I./kernel_call -Wno-unused-variable -Wno-unused-function -Wno-unused-label
inject_LIBRARIES = mis
inject_FRAMEWORKS = Foundation CoreFoundation IOKit Security
inject_FILES = main.m inject.m patchfinder64/patchfinder64.c kern_funcs.c kernel_call/kc_parameters.c kernel_call/kernel_alloc.c kernel_call/kernel_call.c kernel_call/kernel_memory.c kernel_call/kernel_slide.c kernel_call/log.c kernel_call/pac.c kernel_call/parameters.c kernel_call/platform_match.c kernel_call/platform.c kernel_call/user_client.c

include $(THEOS_MAKE_PATH)/tool.mk
