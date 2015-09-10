//
//  SWAcapellaPSListController.m
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

#pragma mark - Override

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

#pragma mark Twitter

- (void)viewTwitterProfile:(PSSpecifier *)specifier
{
    [SWPSTwitterCell performActionWithSpecifier:specifier];
}

@end




