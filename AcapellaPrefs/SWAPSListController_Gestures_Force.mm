//
//  SWAPSListController_Gestures_Force.mm
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAPSListController.h"

#import <Preferences/Preferences.h>

//#import "SWP





@interface SWAPSListController_Gestures_Force : SWAPSListController
{
}

@end





@implementation SWAPSListController_Gestures_Force

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *original = [super loadSpecifiersFromPlistName:plistName target:target];
    
    for (PSSpecifier *specifier in original) { //disable force peek and pop for tap
        
        NSString *specifierKey = [specifier.properties valueForKey:@"key"];
        NSString *specifierDetail = [specifier.properties valueForKey:@"detail"];
        
        if ([specifierKey containsString:@"tap"] &&
            ![specifierKey containsString:@"forcenone"] &&
            [specifierDetail isEqualToString:@"SWAPSListItemsController_Actions"]) {
            [specifier.properties setValue:@NO forKey:@"enabled"];
        }
        
    }
    
    return original;
}

- (NSArray *)actionTitles:(id)target
{
    return @[@"None",
             
             @"Heart",
             @"Up Next",
             
             @"Previous Track",
             @"Next Track",
             @"Interval Rewind",
             @"Interval Forward",
             @"Seek Rewind",
             @"Seek Forward",
             @"Play",
             
             @"Share",
             @"Shuffle",
             @"Repeat",
             @"Contextual",
             
             @"Open App",
             @"Rating",
             @"Decrease Volume",
             @"Increase Volume",
             
             @"EqualizerEverywhere"];
}

- (NSArray *)actionValues:(id)target
{
    return @[@"action_nil",
             
             @"action_heart",
             @"action_upnext",
             
             @"action_previoustrack",
             @"action_nexttrack",
             @"action_intervalrewind",
             @"action_intervalforward",
             @"action_seekrewind",
             @"action_seekforward",
             @"action_playpause",
             
             @"action_share",
             @"action_toggleshuffle",
             @"action_togglerepeat",
             @"action_contextual",
             
             @"action_openapp",
             @"action_showratings",
             @"action_decreasevolume",
             @"action_increasevolume",
             
             @"action_equalizereverywhere"];
}

@end




