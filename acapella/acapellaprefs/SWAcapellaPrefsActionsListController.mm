
#import "SWAcapellaPrefsActionsListController.h"

#import "SWAcapellaPrefsHelper.h"

@implementation SWAcapellaPrefsActionsListController

#pragma mark Init

- (id)specifiers
{
    if (_specifiers == nil) {
        //self.parentController = SWGMCPrefsBundleController so value change will call setPreferenceValue:spec:
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
             @"Open Activity", //6
             @"Show Playlist Options", //7
             @"Open App/Show Ratings", //8
             @"Show Ratings/Open App", //9
             @"Decrease Volume", //10
             @"Increase Volume"]; //11
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

- (void)_returnKeyPressed:(id)pressed
{
    [super _returnKeyPressed:pressed];
    
    //this will dismiss the keyboard and save the preferences for the selected text field
    if ([self isKindOfClass:[UIViewController class]]){
        [((UIViewController *)self).view endEditing:YES];
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    NSDictionary *acapellaPrefs = [NSDictionary dictionaryWithContentsOfFile:SW_ACAPELLA_PREFERENCES_PATH];
    
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
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SW_ACAPELLA_PREFERENCES_PATH]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:SW_ACAPELLA_PREFERENCES_PATH atomically:YES];
    CFStringRef mikotoPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), mikotoPost, NULL, NULL, YES);
}

@end




