




#FINALPACKAGE = 1
PACKAGE_VERSION = 1.1-2





ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





TWEAK_NAME = Acapella2
Acapella2_CFLAGS = -fobjc-arc -Wno-arc-performSelector-leaks
Acapella2_FILES = SWAcapella.m SWAcapellaTitlesCloneContainer.m SWAcapellaTitlesClone.m MPUSystemMediaControlsViewController.xm MPUTransportControlsView.xm MPVolumeController.xm MusicMiniPlayerViewController.xm MusicNowPlayingViewController.xm MusicNowPlayingTitlesView.xm MPUMediaControlsTitlesView.xm SBLockScreenView.xm Prefs.xm
Acapella2_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore
Acapella2_LIBRARIES = substrate sw packageinfo

ADDITIONAL_CFLAGS = -Ipublic





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
