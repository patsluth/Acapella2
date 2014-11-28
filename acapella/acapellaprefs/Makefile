include theos/makefiles/common.mk

BUNDLE_NAME = AcapellaPrefs
AcapellaPrefs_FILES = AcapellaPrefs.mm
AcapellaPrefs_INSTALL_PATH = /Library/PreferenceBundles
AcapellaPrefs_FRAMEWORKS = UIKit
AcapellaPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AcapellaPrefs.plist$(ECHO_END)
