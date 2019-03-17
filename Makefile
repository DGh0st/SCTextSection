export ARCHS = armv7 arm64
export TARGET = iphone:clang:9.3:latest

PACKAGE_VERSION = 0.0.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SCTextSection
SCTextSection_FILES = Tweak.xm
SCTextSection_FRAMEWORKS = UIKit
SCTextSection_PRIVATE_FRAMEWORKS = Preferences
SCTextSection_LIBRARIES = SwitcherControls

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += sctextsection
include $(THEOS_MAKE_PATH)/aggregate.mk
