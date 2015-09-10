//
//  SWAcapellaPSListController_Instance.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "libsw/SWPSListController.h"





@interface SWAcapellaPSListController_Instance : SWPSListController
{
}

@end





@implementation SWAcapellaPSListController_Instance

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




