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
        _specifiers = [self loadSpecifiersFromPlistName:@"AcapellaPrefs" target:self];
    }
    
    return _specifiers;
}

#pragma mark - Override

- (NSString *)bundlePath
{
    return @"/Library/PreferenceBundles/AcapellaPrefs.bundle";
}

- (NSString *)displayName
{
    return @"Acapella";
}

- (NSString *)plistPath
{
    return @"/User/Library/Preferences/com.patsluth.AcapellaPrefs.plist";
}

#pragma mark Tutorial Video

- (void)viewTutorialVideo:(PSSpecifier *)specifier
{
    //random string so php doesnt cache
    NSInteger randomStringLength = 200;
    NSMutableString *randomString = [NSMutableString stringWithCapacity:randomStringLength];
    for (int i = 0; i < randomStringLength; i++){
        [randomString appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",
                     @"http://sluthware.com/SluthwareApps/SWAcapellaTutorialVideoURL.php?",
                     randomString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
                                if (connectionError){
                                    //NSLog(@"SW Error - %@", connectionError);
                                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Could not retrive Video URL"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil] show];
                                } else {
                                    NSString *result = [[NSString alloc] initWithData:data
                                                                             encoding:NSUTF8StringEncoding];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
                                }
                           }];
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




