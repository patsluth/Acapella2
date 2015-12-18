




#define ACAPELLA_PREFS_DEFAULTS_PATH @"/Library/PreferenceBundles/AcapellaPrefs2.bundle"

%ctor //syncronize acapella default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:ACAPELLA_PREFS_DEFAULTS_PATH];
    NSDictionary *prefDefaults = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"acapellaPrefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefDefaults){
        
        NSString *application = [key containsString:@"music"] ? @"com.apple.Music" : @"com.patsluth.AcapellaPrefs2";
        
        id currentValue = (id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key,
                                                                          (__bridge CFStringRef)application));
        
        if (currentValue == nil){ //dont overwrite
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefDefaults valueForKey:key],
                                     (__bridge CFStringRef)application);

        }
        
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize((__bridge CFStringRef)@"com.patsluth.AcapellaPrefs2");
    CFPreferencesAppSynchronize((__bridge CFStringRef)@"com.apple.Music");
    
}




