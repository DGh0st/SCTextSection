include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SCTextSection
SCTextSection_FILES = SCTRootListController.m
SCTextSection_INSTALL_PATH = /Library/PreferenceBundles
SCTextSection_FRAMEWORKS = UIKit MessageUI
SCTextSection_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SCTextSection.plist$(ECHO_END)
