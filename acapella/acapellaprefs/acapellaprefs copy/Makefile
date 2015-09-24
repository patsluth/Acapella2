




ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





BUNDLE_NAME = AcapellaPrefs
AcapellaPrefs_CFLAGS = -fobjc-arc
AcapellaPrefs_FILES = SWAcapellaPSListController.mm SWAcapellaPSListController_Instance.mm SWAcapellaPSListController_ControlCenter.mm
AcapellaPrefs_INSTALL_PATH = /Library/PreferenceBundles
AcapellaPrefs_FRAMEWORKS = UIKit
AcapellaPrefs_PRIVATE_FRAMEWORKS = Preferences
AcapellaPrefs_LIBRARIES = sw

ADDITIONAL_CFLAGS = -Ipublic





include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk





clean::
	rm -rf .theos





internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AcapellaPrefs2.plist$(ECHO_END)




