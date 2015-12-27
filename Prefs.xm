




#define PREFS_DEFAULTS_PATH @"/Library/PreferenceBundles/AcapellaPrefs2.bundle"

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
