//
//  SWAcapellaPSListController.mm
//  AcapellaPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAcapellaPSListController.h"

#import "libsw/libSluthware/libSluthware.h"





@interface SWAcapellaPSListController()
{
}

@end





@implementation SWAcapellaPSListController

- (void)resetAllSettings:(PSSpecifier *)specifier
{
    NSString *prefsDefaultsPath = [self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
    NSString *prefsPath = @"/User/Library/Preferences/com.patsluth.acapella2.plist";
    
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:prefsDefaultsPath];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    
    for (NSString *key in prefsDefaults) {
        
        [prefs setValue:[prefsDefaults valueForKey:key] forKey:key];
        CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                 (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                 CFSTR("com.patsluth.acapella2"));
        
    }
    
    // syncronize so we can read right away
    [prefs writeToFile:prefsPath atomically:YES];
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.acapella2"));
    
    [self reloadSpecifiers];
}

@end




