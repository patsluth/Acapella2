THEOS_PACKAGE_DIR_NAME = debs
THEOS_DEVICE_IP = 192.168.1.149
THEOS_DEVICE_PORT = 22
ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0

TWEAK_NAME = Acapella
Acapella_CFLAGS = -fobjc-arc
Acapella_FILES = Tweak.xm
Acapella_FRAMEWORKS = Foundation UIKit MediaPlayer MessageUI
Acapella_LIBRARIES = sw packageinfo

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -Ipublic/privateheaders

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	@install.exec "killall -9 SpringBoard"
