THEOS_PACKAGE_DIR_NAME = debs

USEWIFI = 1 ###COMMENT OUT TO USE USB

ifdef USEWIFI
	THEOS_DEVICE_IP = 192.168.1.149 			#192.168.1.149======192.168.1.123========192.168.1.133
	THEOS_DEVICE_PORT = 22
else
	THEOS_DEVICE_IP = 127.0.0.1
	THEOS_DEVICE_PORT = 2222
endif

ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0

TWEAK_NAME = Acapella
Acapella_CFLAGS = -fobjc-arc
Acapella_LDFLAGS = -ObjC
Acapella_FILES = AVSystemController.xm SWAcapellaActionsHelper.xm SWAcapellaMusicApp.xm SWAcapellaPrefsBridge.xm SWAcapellaSharingFormatter.m SWAcapellaSpringboard.xm SWAcapellaSystemTitlesView.xm
Acapella_FRAMEWORKS = Foundation CoreGraphics UIKit MediaPlayer MessageUI
Acapella_PRIVATE_FRAMEWORKS = MediaRemote
Acapella_LIBRARIES = substrate sw packageinfo

BUNDLE_NAME = AcapellaSupport
AcapellaSupport_INSTALL_PATH = /Library/Application Support

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -Ipublic/privateheaders
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/MusicApp
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/Shared
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/Springboard
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/SpringboardMusic

SUBPROJECTS += acapellaprefs

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	@install.exec "killall -9 SpringBoard"
