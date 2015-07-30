




ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest





BUNDLE_NAME = AcapellaPrefs2
AcapellaPrefs2_CFLAGS = -fobjc-arc
AcapellaPrefs2_FILES = SWAcapellaPrefsListController.mm SWAcapellaPrefsListController_Instance.mm  SWAcapellaPrefsListController_Actions.mm SWAcapellaPrefsListController_Transport.mm
AcapellaPrefs2_INSTALL_PATH = /Library/PreferenceBundles
AcapellaPrefs2_FRAMEWORKS = UIKit
AcapellaPrefs2_PRIVATE_FRAMEWORKS = Preferences
AcapellaPrefs2_LIBRARIES = sw

ADDITIONAL_CFLAGS = -Ipublic
ADDITIONAL_CFLAGS += -Ipublic/libsw
ADDITIONAL_CFLAGS += -Ipublic/libsw/libSluthware





include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk





clean::
	rm -rf .theos





internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AcapellaPrefs2.plist$(ECHO_END)




