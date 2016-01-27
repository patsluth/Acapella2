//
//  SWAPSListController_Gestures.mm
//  AcapellaPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "SWAcapellaBasePSListController.h"





@interface SWAPSListController_Gestures : SWAcapellaBasePSListController
{
}

@end





@implementation SWAPSListController_Gestures

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




