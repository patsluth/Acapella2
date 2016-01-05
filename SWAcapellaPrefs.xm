//
//  SWAcapellaPrefs.m
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapellaPrefs.h"

#define PREFS_DEFAULTS_PATH @"/Library/PreferenceBundles/AcapellaPrefs2.bundle"





//@interface SWAcapellaPrefs()
//{
//}
//
//@property (strong, nonatomic) NSString *application;
//@property (strong, nonatomic) NSString *keyPrefix;
//
//@property (nonatomic, readwrite) BOOL enabled;
//@property (nonatomic, readwrite) BOOL progressSlider_enabled;
//@property (nonatomic, readwrite) BOOL volumeSlider_enabled;
//
//@end
//
//
//
//
//
//@implementation SWCelloPrefs
//
//- (id)init
//{
//    self = [super init];
//    
//    if (self) {
//        self.application = nil;
//        [self refreshPrefs];
//    }
//    
//    return self;
//}
//
//- (void)refreshPrefs
//{
//    if (self.application) {
//        return;
//    }
//    
//    CGStringRef cfApplication = (__bridge CGStringRef)self.application;
//    
//    self.enabled = CFPreferencesGetAppBooleanValue(CFSTR("cello_popaction_type"), cfApplication, nil);
//    
//    self.progressSlider_enabled = CFPreferencesGetAppBooleanValue(CFSTR("cello_showinstore_peek_enabled"), cfApplication, nil);
//    self.volumeSlider_enabled = CFPreferencesGetAppBooleanValue(CFSTR("cello_startradiostation_peek_enabled"), cfApplication, nil);
//    
//    CFRelease(cfApplication);
//}
//
//@end






%ctor //syncronize acapella default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:PREFS_DEFAULTS_PATH];
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"prefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefsDefaults) {
        
        CFStringRef application = [key containsString:@"music"] ? CFSTR("com.apple.Music") : CFSTR("com.patsluth.AcapellaPrefs2");
        
        id currentValue = (id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, application));
        
        if (currentValue == nil) { //dont overwrite
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                     application);
            
        }
        
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.AcapellaPrefs2"));
    CFPreferencesAppSynchronize(CFSTR("com.apple.Music"));
    
}




