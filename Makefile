




FINALPACKAGE = 1
DEBUG = 0
PACKAGE_VERSION = 1.1-12





ifeq ($(DEBUG), 1)
    ARCHS = arm64
else
    ARCHS = armv7 armv7s arm64
endif
TARGET = iphone:clang:latest:7.0





TWEAK_NAME = Acapella2
Acapella2_CFLAGS = -fobjc-arc -Wno-arc-performSelector-leaks
Acapella2_FILES = MPUMediaControlsTitlesView.xm \
                    MPUSystemMediaControlsViewController.xm \
                    MPUTransportControlsView.xm \
                    MPVolumeController.xm \
                    MusicMiniPlayerViewController.xm \
                    MusicNowPlayingTitlesView.xm \
                    MusicNowPlayingViewController.xm \
                    SBLockScreenHintManager.xm \
                    SWAcapella.m \
                    SWAcapellaMediaItemPreviewViewController.xm \
                    SWAcapellaPrefs.xm \
                    SWAcapellaTitlesClone.m \
                    SWAcapellaTitlesCloneContainer.m \

ifeq ($(DEBUG), 1)
    Acapella2_CFLAGS += -Wno-unused-variable
endif

Acapella2_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore
Acapella2_PRIVATE_FRAMEWORKS = MediaRemote
Acapella2_LIBRARIES = substrate sw packageinfo MobileGestalt

ADDITIONAL_CFLAGS = -Ipublic





BUNDLE_NAME = AcapellaSupport
AcapellaSupport_INSTALL_PATH = /Library/Application Support





SUBPROJECTS += AcapellaPrefs





include theos/makefiles/common.mk
include theos/makefiles/bundle.mk
include theos/makefiles/tweak.mk
include theos/makefiles/aggregate.mk
include theos/makefiles/swcommon.mk





after-install::
	$(ECHO_NOTHING)install.exec "killall -9 Music > /dev/null 2> /dev/null"; echo -n '';$(ECHO_END)
	$(ECHO_NOTHING)install.exec "killall -9 Preferences > /dev/null 2> /dev/null"; echo -n '';$(ECHO_END)
	$(ECHO_NOTHING)install.exec "killall -9 backboardd > /dev/null 2> /dev/null"; echo -n '';$(ECHO_END)




