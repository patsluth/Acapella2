




THEOS_PACKAGE_DIR_NAME = debs
PACKAGE_VERSION = 1.0-4





#USEWIFI = 1 ###COMMENT OUT TO USE USB

ifdef USEWIFI
	THEOS_DEVICE_IP = 192.168.1.120
	THEOS_DEVICE_PORT = 22
else
	THEOS_DEVICE_IP = 127.0.0.1
	THEOS_DEVICE_PORT = 2222
endif





ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





TWEAK_NAME = Acapella2
Acapella2_CFLAGS = -fobjc-arc
Acapella2_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
Acapella2_LIBRARIES = substrate sw packageinfo
Acapella2_FILES = AcapellaTest/AcapellaTest/SWAcapella.m MPUSystemMediaControlsViewController.xm MusicMiniPlayerViewController.xm MusicNowPlayingViewController.xm MusicNowPlayingTitlesView.xm MPUMediaControlsTitlesView.xm SWAcapellaPrefsBridge.xm

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -IAcapellaTest/AcapellaTest/
ADDITIONAL_CFLAGS += -Ipublic/libsw
ADDITIONAL_CFLAGS += -Ipublic/libsw/libSluthware





BUNDLE_NAME = AcapellaSupport
AcapellaSupport_INSTALL_PATH = /Library/Application Support





SUBPROJECTS += acapellaprefs





include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk





clean::
	rm -rf debs
	rm -rf .theos





#stage::
#mkdir -p "$(THEOS_STAGING_DIR)/Library/Frameworks"
#cp -r AcapellaKit.framework "$(THEOS_STAGING_DIR)/Library/Frameworks"





after-install::
	@install.exec "killall -9 SpringBoard"




