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
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:[self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefsDefaults) {
        
        CFStringRef application = [key containsString:@"music"] ? CFSTR("com.apple.Music") : CFSTR("com.patsluth.AcapellaPrefs2");
        
        CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                 (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                 application);
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.AcapellaPrefs2"));
    CFPreferencesAppSynchronize(CFSTR("com.apple.Music"));
    
    [self reloadSpecifiers];
}

@end




