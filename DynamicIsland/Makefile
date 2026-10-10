export ARCHS = arm64
export TARGET = iphone:clang:latest:12.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DynamicIsland

DynamicIsland_FILES = \
	Tweak.xm \
	src/DIWindowController.m \
	src/DynamicIslandView.m \
	src/DICompactView.m \
	src/DIExpandedView.m \
	src/DIActivityManager.m \
	src/DIAnimator.m \
	src/DINotificationProvider.m \
	src/DIMusicProvider.m \
	src/DICallProvider.m \
	src/DIPreferencesManager.m

DynamicIsland_CFLAGS = -fobjc-arc -Isrc -w
DynamicIsland_FRAMEWORKS = UIKit CoreGraphics QuartzCore MediaPlayer CoreTelephony
DynamicIsland_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = DynamicIslandPrefs
DynamicIslandPrefs_FILES = PreferenceBundle/DynamicIslandPrefsController.m
DynamicIslandPrefs_INSTALL_PATH = /Library/PreferenceBundles
DynamicIslandPrefs_PRINCIPAL_CLASS = DynamicIslandPrefsController
DynamicIslandPrefs_CFLAGS = -fobjc-arc
DynamicIslandPrefs_FRAMEWORKS = UIKit
DynamicIslandPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "sbreload"
