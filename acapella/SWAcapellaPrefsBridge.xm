
#import "SWAcapellaPrefsBridge.h"

#pragma mark Preferences

#define SW_ACAPELLA_PREFERENCES_PATH @"/User/Library/Preferences/com.patsluth.AcapellaPrefs.plist"

static NSDictionary *_swAcapellaPreferences;

@implementation SWAcapellaPrefsBridge

+ (NSDictionary *)preferences
{
	return _swAcapellaPreferences;
}

+ (id)valueForKey:(NSString *)key
{
	if (_swAcapellaPreferences && _swAcapellaPreferences[key]){
    	return _swAcapellaPreferences[key];
    }
    
   return nil;
}

@end

#pragma mark logos

static void swAcapellaPreferencesChanged(CFNotificationCenterRef center,
                                        void *observer,
                                        CFStringRef name,
                                        const void *object,
                                        CFDictionaryRef userInfo)
{
    _swAcapellaPreferences = [[NSDictionary alloc] initWithContentsOfFile:SW_ACAPELLA_PREFERENCES_PATH];
}

%ctor
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    nil,
                                    swAcapellaPreferencesChanged,
                                    CFSTR("com.patsluth.AcapellaPrefs.changed"),
                                    nil,
                                    CFNotificationSuspensionBehaviorCoalesce);
    // Load preferences
    swAcapellaPreferencesChanged(nil, nil, nil, nil, nil);
}



