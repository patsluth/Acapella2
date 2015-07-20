
#import "SWAcapellaPrefsBridge.h"

#define SW_ACAPELLA_PREFERENCES_PATH @"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist"





static NSDictionary *_swAcapellaPreferences;





@implementation SWAcapellaPrefsBridge

+ (NSDictionary *)preferences
{
	return _swAcapellaPreferences;
}

+ (id)valueForKey:(NSString *)key defaultValue:(id)defaultValue
{
	if (_swAcapellaPreferences && _swAcapellaPreferences[key]){
        
        id prefValue = _swAcapellaPreferences[key];
        
        if ([prefValue isKindOfClass:[NSString class]] && [prefValue isEqualToString:@""]){
            return defaultValue;
        }
        
    	return _swAcapellaPreferences[key];
    }
    
   return defaultValue;
}

@end





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
                                    CFSTR("com.patsluth.AcapellaPrefs2.changed"),
                                    nil,
                                    CFNotificationSuspensionBehaviorCoalesce);
    // Load preferences
    swAcapellaPreferencesChanged(nil, nil, nil, nil, nil);
}



