




ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0





BUNDLE_NAME = AcapellaPrefs2
AcapellaPrefs2_CFLAGS = -fobjc-arc
AcapellaPrefs2_FILES = SWAcapellaBasePSListController.mm \
						SWAcapellaPSListController.mm \
                        SWAPSListController_Gestures.mm \
                        SWAPSListController_Instance.mm \
                        SWAPSListController_Transport.mm \
                        SWAPSListItemsController_Actions.mm \

AcapellaPrefs2_INSTALL_PATH = /Library/PreferenceBundles
AcapellaPrefs2_FRAMEWORKS = UIKit
AcapellaPrefs2_PRIVATE_FRAMEWORKS = Preferences
AcapellaPrefs2_LIBRARIES = sw

ADDITIONAL_CFLAGS = -Ipublic





include theos/makefiles/common.mk
include theos/makefiles/bundle.mk
include theos/makefiles/swcommon.mk





before-stage::
	$(ECHO_NOTHING)pwd >> temp.txt; echo SWAcapellaPSListController >> temp.txt; cat temp.txt | tr '\n' ';' | ./exportPrefs; rm -r -f temp.txt;$(ECHO_END)





internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AcapellaPrefs2.plist$(ECHO_END)




