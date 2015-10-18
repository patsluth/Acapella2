




THEOS_PACKAGE_DIR_NAME = debs
PACKAGE_VERSION = 1.0-15





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





TWEAK_NAME = Acapella
Acapella_CFLAGS = -fobjc-arc -Wno-arc-performSelector-leaks
Acapella_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
Acapella_LIBRARIES = substrate sw packageinfo
Acapella_FILES = AcapellaTest/AcapellaTest/SWAcapella.m AcapellaTest/AcapellaTest/SWAcapellaTitlesCloneContainer.m AcapellaTest/AcapellaTest/SWAcapellaTitlesClone.m MPUSystemMediaControlsViewController.xm MPUTransportControlsView.xm MPVolumeController.xm MusicMiniPlayerViewController.xm MusicNowPlayingViewController.xm MusicNowPlayingTitlesView.xm MPUMediaControlsTitlesView.xm SBLockScreenView.xm

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -IAcapellaTest/AcapellaTest/





BUNDLE_NAME = AcapellaSupport
AcapellaSupport_INSTALL_PATH = /Library/Application Support





SUBPROJECTS += acapellaprefs/acapellaprefs





include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk





clean::
	rm -rf debs
	rm -rf .theos





after-install::
	install.exec "killall -9 backboardd"
