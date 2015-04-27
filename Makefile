




THEOS_PACKAGE_DIR_NAME = debs
PACKAGE_VERSION=1.1~beta





USEWIFI = 1 ###COMMENT OUT TO USE USB

ifdef USEWIFI
	THEOS_DEVICE_IP = 192.168.1.149
	THEOS_DEVICE_PORT = 22
else
	THEOS_DEVICE_IP = 127.0.0.1
	THEOS_DEVICE_PORT = 2222
endif





ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0





TWEAK_NAME = Acapella
Acapella_CFLAGS = -fobjc-arc
Acapella_FILES = SWAcapellaSpringboard.xm SWAcapellaMusicApp.xm AVSystemController.xm SWAcapellaActionsHelper.xm SWAcapellaPrefsBridge.xm SWAcapellaSharingFormatter.m
Acapella_FRAMEWORKS = Foundation UIKit CoreGraphics MediaPlayer Social
Acapella_PRIVATE_FRAMEWORKS = MediaRemote
Acapella_LIBRARIES = substrate sw packageinfo

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -Ipublic/libsw
ADDITIONAL_CFLAGS += -Ipublic/libsw/libSluthware
ADDITIONAL_CFLAGS += -Ipublic/privateheaders
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/MusicApp
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/Shared
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/Springboard
ADDITIONAL_CFLAGS += -Ipublic/privateheaders/SpringboardMusic
ADDITIONAL_CFLAGS += -IAcapellaKit





BUNDLE_NAME = AcapellaSupport
AcapellaSupport_INSTALL_PATH = /Library/Application Support





#SUBPROJECTS += acapellaprefs





include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk





clean:: 
	rm -r debs
	rm -r .theos





stage::
	mkdir -p "$(THEOS_STAGING_DIR)/Library/Frameworks"
	cp -r AcapellaKit.framework "$(THEOS_STAGING_DIR)/Library/Frameworks"





after-install::
	@install.exec "killall -9 SpringBoard"




