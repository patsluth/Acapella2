//
//  SWAcapellaPSListController.mm
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAcapellaPSListController.h"

#import <Preferences/Preferences.h>

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWPSTwitterCell.h"





@interface SWAcapellaPSListController()
{
}

@end





@implementation SWAcapellaPSListController

- (void)resetAllSettings:(PSSpecifier *)specifier
{
    NSDictionary *prefDefaults = [NSDictionary dictionaryWithContentsOfFile:[self.bundle pathForResource:@"acapellaPrefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefDefaults){
        
        NSString *application = [key containsString:@"music"] ? @"com.apple.Music" : @"com.patsluth.AcapellaPrefs2";
        
        CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                 (__bridge CFPropertyListRef)[prefDefaults valueForKey:key],
                                 (__bridge CFStringRef)application);
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize((__bridge CFStringRef)@"com.patsluth.AcapellaPrefs2");
    CFPreferencesAppSynchronize((__bridge CFStringRef)@"com.apple.Music");
    
}

#pragma mark Twitter

- (void)viewTwitterProfile:(PSSpecifier *)specifier
{
    [SWPSTwitterCell performActionWithSpecifier:specifier];
}

@end




