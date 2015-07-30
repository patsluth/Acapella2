//
//  SWAcapellaPrefsListController.m
//  libsw
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "SWPSListController.h"





@interface SWAcapellaPrefsListController_Actions : SWPSListController
{
}

@end





@implementation SWAcapellaPrefsListController_Actions

#pragma mark Init

- (NSString *)bundlePath
{
    return @"/Library/PreferenceBundles/AcapellaPrefs2.bundle";
}

- (NSString *)displayName
{
    return @"Acapella II";
}

- (NSString *)plistPath
{
    return @"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist";
}

@end




