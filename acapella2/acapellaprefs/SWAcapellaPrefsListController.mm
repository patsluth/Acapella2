//
//  SWAcapellaPrefsListController.m
//  libsw
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAcapellaPrefsListController.h"

#import <Preferences/Preferences.h>

#import "libSluthware.h"
#import "SWPSTwitterCell.h"





@interface SWAcapellaPrefsListController()
{
}

@end





@implementation SWAcapellaPrefsListController

#pragma mark Init

- (id)specifiers
{
    if(_specifiers == nil){
        _specifiers = [self loadSpecifiersFromPlistName:@"AcapellaPrefs2" target:self];
    }
    
    return _specifiers;
}

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

#pragma mark Helper

- (void)_returnKeyPressed:(id)pressed
{
    [super _returnKeyPressed:pressed];
    
    //this will dismiss the keyboard and save the preferences for the selected text field
    if ([self isKindOfClass:[UIViewController class]]){
        [((UIViewController *)self).view endEditing:YES];
    }
}

@end




