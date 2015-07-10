//
//  SWAcapellaPrefsActionsListController.m
//  libsw
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAcapellaPrefsActionsListController.h"





@implementation SWAcapellaPrefsActionsListController

#pragma mark Init

- (id)specifiers
{
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"AcapellaPrefsActions" target:self];
    }
    return _specifiers;
}

- (NSArray *)validActionTitles
{
    return @[@"None", //0
             @"Play/Pause", //1
             @"Previous Song", //2
             @"Next Song", //3
             @"Back 20s", //4
             @"Forward 20s", //5
             @"Show Ratings", //6
             @"Decrease Volume", //7
             @"Increase Volume"]; //8
}

- (NSArray *)validActionValues
{
    NSMutableArray *returnVal = [[NSMutableArray alloc] init];
    
    for (NSUInteger x = 0; x < [self validActionTitles].count; x++){
        [returnVal addObject:[NSNumber numberWithUnsignedInteger:x]];
    }
    
    return returnVal;
}

#pragma mark Helper

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    NSDictionary *acapellaPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist"];
    
    if (!acapellaPrefs[specifier.properties[@"key"]]){
        if (acapellaPrefs[specifier.properties[@"placeholder"]]){
            return specifier.properties[@"placeholder"];
        }
        
        return specifier.properties[@"default"];
    }
    
    return acapellaPrefs[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist"]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:@"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist" atomically:YES];
    CFStringRef mikotoPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), mikotoPost, NULL, NULL, YES);
}

@end




