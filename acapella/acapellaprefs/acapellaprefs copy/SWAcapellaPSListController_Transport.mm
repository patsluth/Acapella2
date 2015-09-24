//
//  SWAcapellaPSListController_Transport.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "libsw/SWPSListController.h"
#import "libsw/SWPrefs.h"





@interface SWAcapellaPSListController_Transport : SWPSListController
{
}

@end





@implementation SWAcapellaPSListController_Transport

- (id)specifiers
{
    if(!_specifiers){
        
        NSArray *transport = [[SWPrefs valueForKey:@"swacapella_cc_prefs" fallbackValue:nil application:@"com.patsluth.AcapellaPrefs2"] valueForKey:@"transport"];
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        for (NSDictionary *item in transport){
            
            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:[item valueForKey:@"label"] target:self set:NULL get:NULL detail:Nil cell:PSSwitchCell edit:Nil];
            UIImage *icon = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:[item valueForKey:@"icon"] ofType:@"png"]];
            [spec setProperty:icon forKey:@"iconImage"];
            [specifiers addObject:spec];
            
        }
        
        _specifiers = [specifiers copy];
        
    }
    
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
//    NSDictionary *transport = [[SWPrefs valueForKey:@"swacapella_cc_prefs" fallbackValue:nil application:@"com.patsluth.AcapellaPrefs2"] valueForKey:@"transport"];
//    
//    for (NSArray *item in transport){
//        
//    }
//    
//    return [transport valueForKey:specifier.properties[@"key"]];
    
    return @YES;
}

#pragma mark Init

- (NSString *)displayName
{
    return @"Acapella II";
}

- (NSString *)plistPath
{
    return @"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist";
}

@end




